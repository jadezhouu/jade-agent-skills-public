# Architecture and Migration Guide

## Synchronize Architecture Documentation

1. Locate the documents and implementation that own the relevant rules. Follow the target project's organization; do not require a dedicated domain directory or architecture summary.
2. For each affected claim, verify implementation, configuration, and relevant tests, recording claim → evidence → update location. Line numbers can drift, so prefer retaining symbol names as well. Passing tests support only the behavior they actually cover.
3. Update the owning domain contract first, then check cross-domain relationships. Check and update boundaries such as dependencies, data ownership, concurrency, lifecycle, and failure recovery only when affected by this change.
4. If the project separates detailed architecture from a short summary, keep details in domain documents and retain only system boundaries, global invariants, and navigation in the summary. Update the overview only when topology or cross-domain relationships change. Do not duplicate full documents or introduce fixed character, page, or line limits unless the project already requires them.
5. Check entry links and anchors. Maintain versions and dates according to existing project rules; do not invent a versioning mechanism for wording changes.

If implementation is inaccessible, record claims awaiting verification and the evidence needed, but do not present speculation as current fact. If a document describes a target design, identify its design status and differences from the current implementation.

## Migrate Historical Material

1. Inventory sources, destinations, current references, and the nature of the material, distinguishing current rules, historical process, and unverified content. Prefer a minimal migration map; perform moves and reference repairs only when migration is in the user's task scope.
2. Preserve the meaning and original conclusions of historical text. Path changes can be repaired and recorded. Add explicit notes for corrections rather than silently rewriting history as present-day facts. Delete duplicates only within the authorized task scope and after confirming retained content and references.
3. Record old-to-new locations and unresolved references. Do not redirect references solely by matching filenames; if candidates are ambiguous, retain the issue and verify context before repair.
4. For migrations requiring content preservation, record and compare hashes before and after migration. Reference repairs change hashes, so inspect whether differences consist only of expected path edits. Do not require identical hashes after edits or classify every difference as a path repair.
5. Reverify code, configuration, or validation evidence when extracting current specifications from historical material. Record migration completion separately from current-state verification; check incoming links, outgoing links, indexes, and the migration map for consistency afterward.

An existing check baseline represents known issues, not resolved issues. When using an existing project baseline mechanism, retain reviewable differences and a reduction plan; do not regenerate a more permissive baseline just to pass acceptance checks.
