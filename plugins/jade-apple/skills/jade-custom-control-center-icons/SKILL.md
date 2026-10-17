---
name: jade-custom-control-center-icons
description: >
  Create custom symbol icons for iOS 18+ ControlWidget controls and diagnose blank or question-mark icons:
  resource membership, template sizing, the v4 SVG structure, and actool/assetutil verification.
  Use for Control Center custom icons, symbolsets, Symbol Image Sets, SF Symbols templates,
  icon sizing and control occupancy, or ControlWidget icon failures. Menu bar images are supplemental
  context for a shared resource pipeline, not a trigger for general icon design.
working-directory: .
---

# Custom Control Center Icons

## Prerequisites and Evidence Boundaries

For custom symbols in iOS 18+ ControlWidget controls. Tools require macOS, full Xcode with the iOS SDK, actool, assetutil, Swift, and Python 3. Device rendering requires separate confirmation. macOS menu bar guidance is supplemental; no watchOS validation is claimed.

Run commands from the frontmatter `working-directory` (the installed skill root), supplying actual target-project catalog and extension paths. Do not depend on a specific skill installation directory. Scripts and the template ship with the English installation; the Chinese authoring source uses the repository's shared resource pipeline.

The v4, fill, layout, and sizing findings come from prior practical work whose original OS/Xcode versions were not fully recorded. Retain this validated workflow as a starting point; recheck compiled output and devices after toolchain upgrades. Official foundations: [Apple controls documentation](https://developer.apple.com/documentation/widgetkit/creating-controls-to-perform-actions-across-the-system) and [custom symbol documentation](https://developer.apple.com/documentation/uikit/creating-custom-symbol-images-for-your-app).

## Read This First

Whether the icon displays depends on its compiled representation as well as its geometry. This workflow requires `Template Version 4`.

In the recorded workflow, actool accepted v0 symbols and AppKit and in-app previews rendered them, while Control Center was blank. Local visibility alone is insufficient: metadata provides compilation evidence; device rendering provides end-to-end evidence.

## 0. Check Feasibility

| Request | Outcome |
| --- | --- |
| A custom symbol as a control icon | Supported by this workflow |
| An existing system symbol | Use Image(systemName:); no custom asset is needed |
| Arbitrary user-selected PNGs or photos as control icons | Not supported by this symbol-image workflow; no runtime bitmap-to-symbol API is provided here |
| User-selectable icons | Bundle predefined custom symbols and expose selection through AppIntentControlConfiguration, rather than arbitrary file selection |

Explain an unsupported bitmap request before implementing it; offer bundled symbol choices instead of hoping a bitmap will render.

## 1. Resource Loading Constraints

1. Use a symbol image, not an ordinary bitmap imageset, for Control Center.
2. Make the symbol available from the resource bundle actually loaded by the extension. This workflow uses default Image("name") lookup; separate resource bundles require explicit selection and separate verification. Main-app-only resources are insufficient. Share the catalog with the app when preview or reuse is needed, using the project's target membership setup.
3. Use Image("CustomName") for named custom assets; Image(systemName:) resolves system symbols.

## 2. Workflow

### Step 1 — Identify the Surface and Name

- Choose a unique, prefixed name such as ExampleNewNote; avoid collisions with system names.
- Keep a single enum or constant definition, such as ControlCenterIcon.swift, for extension rendering and app previews so their names cannot drift.

### Step 2 — Construct Geometry

- Prior symbol-template tests used nonzero winding; fill-rule="evenodd" was ignored. Express holes with opposite subpath winding: outer CCW and holes CW in the working coordinate system.
- Do not use a separate reversed path to implicitly erase another element; that assumes independent path elements are combined for winding evaluation.
- Use a true Boolean difference, such as CGPath.subtracting on supported SDKs. Reversing a cutter contour and appending it fails when the cutter extends outside the host: the outside area has nonzero winding and fills instead. Edge-cutting clear plates commonly expose this as a solid diagonal strip, blob, or unwanted hole.
- The original generator combined paths by appending while preserving winding; do not confuse that operation with a general Boolean union.
- Do not reorient Boolean results or font glyphs by nesting depth. Boolean output already has coherent winding; glyph contours can overlap in the same direction, and depth-based reversal can cancel their overlap. Preserve winding on import. If nesting analysis is necessary, choose a point just inside the contour's material near its boundary, not its centroid: a ring's centroid may lie in its hole.
- Add generation-time sampling assertions for known filled and empty regions, including ring bands, clear areas, and badge centers. Abort without writing output when they fail.
- Measure against system symbols. See [template geometry](references/symbol-template-contract.md), section 9, and [sizing](references/sizing.md). The [measurement script](scripts/measure-symbol.swift) reports rendered ink bounds; the sizing reference retains measured examples.
- Draw original geometry and use system symbols as measurement references. Font outlines and other materials remain subject to their licenses; CoreText's ability to extract an outline does not grant redistribution rights.

### Step 3 — Set Size by Measurement

Do not rely on host fit-to-box behavior to compensate for geometry in this template workflow:

```text
rendered size = design units × pointSize / 100
```

Fix internal size in geometry rather than relying on Control Center .font, .imageScale, frames, or .scaleEffect. A resource may also appear on the Lock Screen or Action Button.

```bash
swift scripts/measure-symbol.swift system camera text.pad.header.badge.plus
```

Then adjust the generator's overallScale, regenerate, compile into a real bundle, measure the result, and compare at the same point size.

Compare ink area as well as bounds: camera and camera.fill had equal bounds but 2.2× different ink area. For the measured circular control, 48%–52% occupancy was a useful starting point. Badge readability targets were cap height ≥32 units and strokes ≥6 units. These are empirical starting points, not universal host guarantees. See [sizing](references/sizing.md) for the table, conversions, pitfalls, and the separate menu bar imageset guidance.

### Step 4 — Use the v4 Template Structure

An arbitrary SVG is not a symbol template. Retain the structure and replace the glyph paths inside Symbols:

- Notes includes text with id="template-version" and value Template v.4.0; removing it produced v0 in prior tests.
- Guides contains Baseline/Capline-S/M/L and fixed margins for supplied glyphs. With minX normalized to zero, the right guide is the origin plus width; with optical offset, use actual maxX.
- Symbols includes Regular-S/M/L. Additional weights require corresponding guides; do not copy margins for missing glyphs.
- Each layer in the supplied profile uses monochrome-1, multicolor-1:tintColor, and hierarchical-1:primary classes.

Use [the template](assets/symbol-template.svg), replacing {{GLYPH_PATH_DATA}}, {{SYMBOL_NAME}}, and {{RIGHT_MARGIN_X}}. Details and actool diagnostics are in [the template contract](references/symbol-template-contract.md).

Once a project has a generator, edit it and regenerate rather than hand-editing generated SVGs and bypassing geometry checks.

### Step 5 — Integrate Assets and Code

```text
<shared-directory>/ControlCenterIcons.xcassets/
  ExampleNewNote.symbolset/
    Contents.json
    ExampleNewNote.svg
```

Compile the catalog into the extension and, if needed, the app. Contents.json uses a symbols array (Symbol Image Set), not images (ordinary imageset).

### Step 6 — Add Structural Guard Tests

Assert the profile's prerequisites in source: Template v.4.0, Notes, Regular-S/M/L, all Baseline/Capline guides, per-scale margins, rendering classes, and no fill-rule dependency. Add corresponding tests in the target project; this skill contains no project-specific test class or generator.

### Step 7 — Run the Verification Gate

```bash
bash scripts/verify-symbols.sh <catalog.xcassets> --appex <Extension.appex>
```

The gate checks source structure, actool output for v4 and S/M/L, and the real extension's Assets.car. Without --appex, packaging is not checked. A nonzero result requires investigation before release. See [verification](references/verification.md) for supported layouts and limits.

### Step 8 — Confirm on a Device

System controls use a separate rendering path; the supplied tools do not automate adding a simulator control or checking its final appearance.

- Remove the old control and add it again to eliminate cached appearance.
- If it still fails, follow the [failure table](references/verification.md) before repeatedly changing geometry.

## 3. Anti-Patterns

| Anti-pattern | Failure |
| --- | --- |
| Treating an in-app preview as proof of Control Center rendering | It exercises a different host; v0 rendered there in prior tests |
| Waiting until device testing to inspect compiled assets | Inspect L1/L2/L3 first; metadata still does not replace device confirmation |
| A minimal SVG skeleton with only Regular-M | actool may accept it as v0 |
| evenodd holes or implicit cross-element erasure | The tested pipeline uses nonzero winding |
| Reversed contour appended as subtraction | Cutter portions outside the host fill instead |
| Depth-based reorientation of overlapping font contours | Overlaps can cancel into holes |
| Eyeballing size or comparing only bounds | Ink area and stroke thickness change visual weight |
| Host transforms to repair internal geometry | Other hosts can expose the same error |
| Badge text that only looks readable in enlarged previews | Verify final cap and stroke sizes |
| Copying the visible center of a badged reference | Some measured references were offset by 4–13%; normalize position independently |
| Only Regular-M or margins for missing weights | Missing glyphs or actool guide errors |
| Main-app-only resources | Default extension lookup cannot find them |
| Editing generated SVGs | Bypasses checks and gets overwritten |

## 4. Generic Integration

Locate the project's generator, catalog, extension target, and name definitions, then follow [integration](references/integration.md). Do not invent project paths or require another skill.

## References

- [Template contract](references/symbol-template-contract.md): v4 structure, coordinates, winding, Boolean operations, geometry measurement, centering.
- [Sizing](references/sizing.md): measured dimensions, ink area, occupancy, readability, scaling, screenshots, and menu bar differences.
- [Verification](references/verification.md): source, compiled output, packaging, device checks, and failure diagnosis.
- [Integration](references/integration.md): project-independent resource and generator workflow.
- [Template](assets/symbol-template.svg): reusable v4 skeleton.
- [Verification script](scripts/verify-symbols.sh): the profile's three-layer gate.
- [Measurement script](scripts/measure-symbol.swift): rendered ink bounds, baseline-relative edges, center offset, coverage, and ink area.
