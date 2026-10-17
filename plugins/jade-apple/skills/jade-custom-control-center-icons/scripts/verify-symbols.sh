#!/usr/bin/env bash
# Verify the supplied Regular-only, single-layer v4 symbol profile.
# Requires macOS, Xcode with the iOS SDK, xcrun and Python 3.
# Compiled metadata is evidence, not a guarantee of device rendering.
set -euo pipefail

usage() {
    echo 'Usage: verify-symbols.sh <catalog.xcassets> [--appex <Extension.appex>]'
    echo 'Exit: 0 requested checks passed; 1 check failed; 2 invalid usage.'
    echo 'Without --appex, packaged extension resources are NOT checked.'
}

CATALOG=""
APPEX=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --appex)
            [[ $# -ge 2 ]] || { echo "Error: --appex requires a path" >&2; exit 2; }
            APPEX="$2"; shift 2 ;;
        -h|--help)
            usage; exit 0 ;;
        -*)
            echo "Error: unknown argument $1" >&2; usage >&2; exit 2 ;;
        *)
            CATALOG="$1"; shift ;;
    esac
done

[[ -n "$CATALOG" ]] || { echo "Error: missing .xcassets path" >&2; usage >&2; exit 2; }
[[ -d "$CATALOG" ]] || { echo "Error: not a directory: $CATALOG" >&2; exit 2; }

TMPDIR_RUN="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_RUN"' EXIT

FAILED=0
step() { printf '\n\033[1m▸ %s\033[0m\n' "$1"; }

# ─────────────────────────────────────────────────────────────────────────────
step "1/3 Source: v4 template structure"

python3 - "$CATALOG" <<'PY' || FAILED=1
import json, pathlib, re, sys

catalog = pathlib.Path(sys.argv[1])
sets = sorted(p for p in catalog.iterdir() if p.is_dir() and p.suffix == ".symbolset")
if not sets:
    print(f"  ✗ {catalog} contains no top-level .symbolset")
    sys.exit(1)

problems = []
for ss in sets:
    name = ss.stem
    def bad(msg):
        problems.append(f"{name}: {msg}")

    contents = ss / "Contents.json"
    svg_file = ss / f"{name}.svg"

    if not contents.is_file():
        bad("Missing Contents.json"); continue
    try:
        meta = json.loads(contents.read_text())
    except json.JSONDecodeError as exc:
        bad(f"Invalid Contents.json: {exc}"); continue
    if not isinstance(meta.get("symbols"), list) or not meta["symbols"]:
        bad('Contents.json needs a symbols array (Symbol Image Set, not an imageset)')

    if not svg_file.is_file():
        bad(f"Missing {name}.svg"); continue
    svg = svg_file.read_text()

    if 'id="template-version"' not in svg or "Template v.4.0" not in svg:
        bad('Missing <text id="template-version">Template v.4.0</text>')
    if 'id="Notes"' not in svg:
        bad('Missing <g id="Notes">')

    for scale in ("S", "M", "L"):
        for guide in ("Baseline", "Capline"):
            if f'id="{guide}-{scale}"' not in svg:
                bad(f"Missing {guide}-{scale} guide")
        if f'<g id="Regular-{scale}"' not in svg:
            bad(f"Missing Regular-{scale} glyph group")
        for side in ("left", "right"):
            if f'id="{side}-margin-Regular-{scale}"' not in svg:
                bad(f"Missing {side}-margin-Regular-{scale} fixed margin guide")

    weights = set(re.findall(r'id="(?:left|right)-margin-([A-Za-z]+)-[SML]"', svg))
    glyph_weights = set(re.findall(r'<g id="([A-Za-z]+)-[SML]"', svg)) - {"Regular"}
    stray = weights - {"Regular"}
    if stray:
        bad(f"Unsupported non-Regular margins {sorted(stray)}; actool may report "
            f'"interpolatable margin guides for missing glyphs"')
    if glyph_weights:
        bad(f"Non-Regular glyph groups {sorted(glyph_weights)} are outside this checker profile")

    if "fill-rule" in svg:
        bad('fill-rule is outside this profile; use nonzero winding and explicit geometry')

    paths = [l for l in svg.splitlines() if "<path" in l and "class=" in l]
    if not paths:
        bad("No layer path with rendering classes")
    for line in paths:
        for cls in ("monochrome-1", "multicolor-1:tintColor", "hierarchical-1:primary"):
            if cls not in line:
                bad(f"Layer missing rendering class: {cls}")

if problems:
    for p in problems:
        print(f"  ✗ {p}")
    sys.exit(1)
print(f"  ✓ {len(sets)} symbol sets have the required structure: {', '.join(s.stem for s in sets)}")
PY

# ─────────────────────────────────────────────────────────────────────────────
step "2/3 Compilation: require Template Version 4"

mkdir -p "$TMPDIR_RUN/catalog"
if ! xcrun actool \
        --output-format human-readable-text \
        --errors --warnings --notices \
        --target-device iphone \
        --minimum-deployment-target 18.0 \
        --platform iphoneos \
        --compile "$TMPDIR_RUN/catalog" \
        "$CATALOG"; then
    echo "  ✗ actool compilation failed; inspect diagnostics above"
    FAILED=1
fi

if [[ -f "$TMPDIR_RUN/catalog/Assets.car" ]]; then
    xcrun assetutil --info "$TMPDIR_RUN/catalog/Assets.car" > "$TMPDIR_RUN/catalog.json"
    python3 - "$TMPDIR_RUN/catalog.json" "$CATALOG" <<'PY' || FAILED=1
import json, pathlib, sys

entries = json.load(open(sys.argv[1]))
catalog = pathlib.Path(sys.argv[2])
expected = sorted(p.stem for p in catalog.iterdir() if p.is_dir() and p.suffix == ".symbolset")

glyphs = [e for e in entries if isinstance(e, dict) and e.get("AssetType") == "Vector Glyph"]
if not glyphs:
    print("  ✗ No Vector Glyph in compiled output; inspect the template")
    sys.exit(1)

by_name = {}
for g in glyphs:
    by_name.setdefault(g["Name"], []).append(g)

problems = []
for name in expected:
    got = by_name.get(name)
    if not got:
        problems.append(f"{name}: Vector Glyph missing from compiled output")
        continue
    sizes = {g.get("Glyph Size") for g in got}
    versions = {g.get("Template Version") for g in got}
    if sizes != {"Small", "Medium", "Large"}:
        problems.append(f"{name}: glyph sizes are {sorted(sizes)}, expected Small/Medium/Large")
    if versions != {4}:
        problems.append(
            f"{name}: Template Version = {sorted(versions)}, expected 4"
            " (v0 failed in the recorded Control Center workflow)"
        )
    for g in got:
        if g.get("Glyph Size") == "Medium" and not g.get("Available Sizes"):
            problems.append(f"{name}: Medium glyph missing Available Sizes metadata")

for name in sorted(set(by_name) - set(expected)):
    problems.append(f"{name}: unexpected compiled symbol (stale resource or name drift)")

if problems:
    for p in problems:
        print(f"  ✗ {p}")
    sys.exit(1)
for name in expected:
    sizes = sorted(g["Glyph Size"] for g in by_name[name])
    print(f"  ✓ {name}: Vector Glyph {sizes}, Template Version 4")
PY
else
    echo "  ✗ actool did not produce Assets.car"
    FAILED=1
fi

# ─────────────────────────────────────────────────────────────────────────────
if [[ -n "$APPEX" ]]; then
    step "3/3 Packaging: check extension bundle resources"
    CAR="$APPEX/Assets.car"
    if [[ ! -f "$CAR" ]]; then
        echo "  ✗ Missing $CAR; check extension resource membership"
        echo "    This checker expects symbols in the extension Assets.car, not only in the main app."
        FAILED=1
    else
        xcrun assetutil --info "$CAR" > "$TMPDIR_RUN/appex.json"
        python3 - "$TMPDIR_RUN/appex.json" "$CATALOG" <<'PY' || FAILED=1
import json, pathlib, sys

entries = json.load(open(sys.argv[1]))
catalog = pathlib.Path(sys.argv[2])
expected = sorted(p.stem for p in catalog.iterdir() if p.is_dir() and p.suffix == ".symbolset")

glyphs = [e for e in entries if isinstance(e, dict) and e.get("AssetType") == "Vector Glyph"]
by_name = {}
for g in glyphs:
    by_name.setdefault(g["Name"], []).append(g)

problems = []
for name in expected:
    got = by_name.get(name)
    if not got:
        problems.append(f"{name}: missing from extension Assets.car")
        continue
    sizes = {g.get("Glyph Size") for g in got}
    if sizes != {"Small", "Medium", "Large"}:
        problems.append(f"{name}: extension missing Small/Medium/Large glyphs: {sizes}")
    versions = {g.get("Template Version") for g in got}
    if versions != {4}:
        problems.append(f"{name}: extension Template Version = {sorted(versions)}, expected 4")
if problems:
    for p in problems:
        print(f"  ✗ {p}")
    sys.exit(1)
print(f"  ✓ extension contains {len(expected)} symbols with Template Version 4 and S/M/L")
PY
    fi
else
    step "3/3 Packaging: SKIPPED (no --appex)"
    echo "  · Before release, check the real extension; see references/verification.md"
fi

# ─────────────────────────────────────────────────────────────────────────────
printf '\n'
if [[ "$FAILED" -eq 0 ]]; then
    printf '\033[32mRequested checks passed\033[0m — Device rendering remains unverified.\n'
else
    printf '\033[31mChecks failed\033[0m — See diagnostics above and references/symbol-template-contract.md\n'
fi
exit "$FAILED"
