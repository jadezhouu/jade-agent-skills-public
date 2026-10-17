# Verification and Troubleshooting

## 1. Evidence Chain

| Layer | Check | Does not prove |
| --- | --- | --- |
| L1 source | SVG matches this template profile | Compiled version |
| L2 compilation | actool output contains Vector Glyph, v4, and S/M/L | Extension membership or device rendering |
| L3 packaging | Real extension Assets.car contains expected symbols, v4, and S/M/L | Final system appearance |
| L4 device | Actual system control appearance, size, centering, and state | Compatibility on untested OS/device versions |

An in-app preview can inspect geometry but is not Control Center end-to-end evidence. Template version is important compilation evidence, not sufficient proof of display success.

## 2. Run the Gate

From the installed skill root, substitute actual project paths:

```bash
bash scripts/verify-symbols.sh <catalog.xcassets> --appex <Extension.appex>
```

Without --appex, only L1/L2 run. Exit 0 means requested checks passed, 1 means check failure, and 2 means usage error; missing tools or tool failures may produce other nonzero codes. Skipped L3 or L4 is not full acceptance.

The script intentionally retains the original profile: top-level symbolsets, SVG filenames matching directory names, Regular S/M/L, single-layer rendering classes, iPhone/iOS 18.0 compilation, and Assets.car at the extension root. It is not a general SVG/schema validator and does not support every valid layered, multiweight, namespaced-directory, or separate-resource-bundle layout. Adapt verification for other layouts rather than damaging valid assets to satisfy this script.

The script creates no artwork generator, does not verify every Contents.json filename mapping, and uses structural checks rather than full XML semantics. Check both source and actual packaged output instead of validating only a temporary compilation.

## 3. Build and Inspect Artifacts

Confirm the actual scheme, SDK, signing configuration, and deployment target before building from the project directory. Prefer a scheme when SPM dependencies require the full dependency graph; one project's target-build failure is not a universal restriction.

For manual investigation, compile the catalog in a temporary directory and inspect it:

```bash
ICON_CHECK_DIR="$(mktemp -d)"
xcrun actool --output-format human-readable-text --errors --warnings --notices \
  --target-device iphone --minimum-deployment-target 18.0 --platform iphoneos \
  --compile "$ICON_CHECK_DIR" <catalog.xcassets>
xcrun assetutil --info "$ICON_CHECK_DIR/Assets.car"
xcrun assetutil --info <Extension.appex/Assets.car>
```

Inspect JSON entries whose AssetType is Vector Glyph: Name matches lookup, Template Version is 4, Glyph Size covers Small/Medium/Large, and Medium has Available Sizes. Reference Point Size, Capline, and Glyph Weight should match the template. Contains Multicolor Layers / Contains Hierarchical Layers help inspect annotations. Do not judge template version from same-named Image bitmap cache entries.

SF Symbols Validate Templates can supplement checks manually; do not assume its coverage is identical to actool compilation.

## 4. Device Confirmation

1. Install the new build and record Xcode, SDK, OS, device, and build version.
2. Remove the old control and add it again to exclude appearance caching.
3. Check each bundled icon, supported control size, and state. Verify Control Center, Lock Screen, or Action Button hosts within the target's supported scope.
4. Inspect light/dark appearance, clarity, centering, and occupancy; retain screenshots and results. These tools do not automate L4. In-app ImageRenderer or geometry snapshots are not equivalent to system-host screenshots.

## 5. Failure Modes

| Symptom | Investigation and remedy |
| --- | --- |
| In-app preview works; Control Center is blank | Verify v4 output, names, and extension resources before changing geometry repeatedly |
| Blank or question mark | Check symbolset, symbols array, actual bundle, and lookup name; do not use Image(systemName:) for a custom asset |
| Solid block or unreadable badge | Check winding, Boolean output, and final stroke sizes |
| Non-Medium scale is blank | Inspect S/M/L in the actual artifact |
| Missing baseline, Regular-M, or margins | Restore corresponding template structure |
| Interpolatable margins for missing glyphs | Remove unmatched guides or add intended glyphs |
| Appearance does not change | Verify artifact and membership; use an isolated build directory to exclude incremental caching, then remove and re-add the control; do not default to deleting all DerivedData |

Extension localization must likewise be available from the bundle it actually loads; do not assume the main app's catalog is automatically accessible. Check localization only when relevant to the current task.
