# Conditional constraints

Read only the relevant sections; use target SDK availability and validation on the corresponding OS to establish version support.

## CloudKit

Apply these constraints only to stores using SwiftData's automatic CloudKit synchronization:

- Do not use `@Attribute(.unique)` or `#Unique`; CloudKit does not support these uniqueness constraints. When deduplication is required, define business identity and conflict handling rather than assuming local checks prevent simultaneous inserts on multiple devices.
- Attributes need optional types or default values; relationships must be optional and have valid inverses. An empty-array default does not replace relationship optionality.
- Do not use the `.deny` delete rule; local deletion checks do not provide strong consistency across devices.
- Synchronization is eventually consistent: handle relationships that have not arrived, offline edits, and duplicates. Successful `save()` confirms local persistence, not receipt on another device.

Check the actual container configuration, entitlements, and CloudKit schema environment; compiling models alone does not establish working synchronization. See [Apple's synchronization guide](https://developer.apple.com/documentation/swiftdata/syncing-model-data-across-a-persons-devices).

## Query performance

Consider `#Index`, fetch limits, relationship prefetching, or reduced fetched properties only with actual data volumes and hot queries; weigh read benefits against write costs instead of indexing every field. Basic `#Index` availability starts at macOS 15, iOS 18, and watchOS 11; check new overloads separately.

Choose search matching by product semantics: consider `localizedStandardContains()` for natural-language search, without automatically replacing exact matching with localized fuzzy matching. For unsupported predicates, first look for a supported equivalent; if filtering in memory, explain the effects on data volume, pagination, and sorting rather than silently loading the entire table.

See [What's new in SwiftData, WWDC24](https://developer.apple.com/videos/play/wwdc2024/10137/).

## Model inheritance and evolution

Consider inheritance only for natural parent/subtype relationships that need polymorphic queries; sharing a few fields is insufficient reason to introduce inheritance. SwiftData model inheritance requires the version 26 OS family; check macOS, iOS, and watchOS targets separately.

Apply `@Model` to both parent and child classes, and explicitly include the required persistent parent and child types in the schema. Annotate subclass availability as required by the SDK macros; do not casually remove annotations because the deployment target is already high enough. Parent-type queries include subtypes, while results are accessed through their declared static type.

Adding inheritance to released models changes the schema; consider old-data migration rather than validating only a fresh container. See [SwiftData inheritance and migration, WWDC25](https://developer.apple.com/videos/play/wwdc2025/291/).

## Evidence boundaries

Official sources and local SDK interfaces were checked on 2026-10-16; this is not a runtime guarantee across versions. See also [ModelContext](https://developer.apple.com/documentation/swiftdata/modelcontext) for save and context APIs. When an empirical rule conflicts with target SDK behavior, update the conclusion using applicable official sources and a minimal reproduction instead of extending an old defect to other versions.
