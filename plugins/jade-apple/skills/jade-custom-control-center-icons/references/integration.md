# Generic Integration Workflow

## 1. Locate Asset Responsibilities

| Responsibility | Target-project asset to identify |
| --- | --- |
| Geometry source of truth | Existing generator or maintained vector source; do not assume a script name |
| Control Center resources | Symbolsets compiled into the extension's actual resource bundle |
| Symbol names | Constants or an enum shared by extension and app previews |
| Controls and actions | ControlWidget and corresponding AppIntent |
| Verification | Geometry samples, template structure, compiled output, real extension, and device records |

For existing symbols, edit the source of truth and regenerate. For new symbols, update name definitions, resource membership, control references, and relevant tests. Adding an icon does not automatically require adding a control or action; follow the user's feature scope. App previews are optional diagnostics, not replacements for device acceptance.

## 2. Sequence and Deliverables

1. Define geometry and sampling points in the generator, then apply unified layout after Boolean composition. Do not write assets if checks fail.
2. Generate SVG and symbols-based Contents.json using the template. This skill includes a template and verification tools, not a project-specific artwork generator.
3. Load with Image("ExampleNewNote") in the extension. Explicitly select and verify separate resource bundles if used. Include the same assets in the main app only when needed for preview or reuse.
4. Run structural checks and L2, build the actual target, run L3, and record L4. See [verification](verification.md) for commands and limits.
5. Update only affected resource documentation, name tables, and tests. Do not depend on particular architecture files, change identifiers, or sibling skills.

## 3. macOS Menu Bar Differences

Control Center uses symbolsets; a menu bar can use an ordinary template imageset with preserves-vector-representation and template-rendering-intent configured for the project. Both may share original geometry, but output format, units, and hosts differ. Do not apply the symbol v4 requirement to ordinary imagesets.

Load the image from the real application bundle through Bundle.image(forResource:), apply the actual status-item canvas's contain/centering behavior, and measure the glyph. Retaining an established canvas avoids changes in status-item occupancy; intentionally changing host layout is a separate task. See [sizing](sizing.md), section 10, for details and empirical starting points.
