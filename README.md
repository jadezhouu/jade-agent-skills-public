English · [简体中文](README.zh-CN.md)

# Jade Agent Skills

Portable skills for AI coding agents: React performance work, Apple platform development, and
project documentation structure. Each skill is a self-contained workflow with its own triggers,
steps, and references — install only what you need.

## What is in here

Three packages, each independently versioned. A package is the install-and-version unit; a skill is
the smallest installable unit.

| Package | Skill | What it does |
| --- | --- | --- |
| `jade-react` | `jade-react-performance` | Diagnose and improve React loading, request waterfalls, interaction latency, and redundant rendering; includes conditional Next.js/RSC guidance |
| `jade-apple` | `jade-swiftdata` | Implement, debug, or review SwiftData models, queries, saving, concurrency, and schema migrations |
| `jade-apple` | `jade-swift-concurrency` | Implement, debug, or review actor isolation, `Sendable` diagnostics, task cancellation, callback-to-async bridging, and Swift 6 migration |
| `jade-apple` | `jade-custom-control-center-icons` | Create custom Control Center symbols for iOS 18+ and diagnose blank or question-mark icons, including `actool`/`assetutil` verification |
| `jade-project` | `jade-design-maintained-project-docs` | Design, establish, or adapt documentation structures for continuously maintained projects |
| `jade-project` | `jade-design-lightweight-project-docs` | Establish a minimal documentation structure for small libraries, tools, and prototypes |
| `jade-project` | `jade-maintain-dev-docs` | Govern documentation: change records, architecture sync, decisions, handoffs, and migration |

Every skill respects the conventions of the project it runs in. None of them requires another skill
from this repository, and none of them depends on files outside its own folder.

## Install with npx (recommended)

```bash
# see all seven skills
npx skills add jadezhouu/jade-agent-skills-public --list

# one skill
npx skills add jadezhouu/jade-agent-skills-public --skill jade-swiftdata -a codex -y

# several skills
npx skills add jadezhouu/jade-agent-skills-public --skill jade-swiftdata \
  --skill jade-maintain-dev-docs -a codex -y

# all seven
npx skills add jadezhouu/jade-agent-skills-public --skill '*' -a codex -y
```

This uses the third-party [`skills`](https://www.npmjs.com/package/skills) CLI (verified with
version 1.7.2) and requires **Node.js >= 22.20.0**. It copies the selected skills into
`.agents/skills/` (project) or the directory your client expects, records the source and a content
hash in `skills-lock.json`, and needs no credentials for this public repository.

- Project-level install is the default; add `-g` for user-level.
- `-y` is required when no terminal prompt is available. `--copy` forces copying.
- Interactive selection and the symlink option were not verified. The non-interactive,
  copy-mode install was: file paths, file contents, and the `0755` modes of bundled scripts match
  this repository byte for byte, with no symlinks created.

Update and restore:

```bash
npx skills update jade-swiftdata -y -p     # re-fetch from the recorded source
npx skills experimental_install            # restore recorded content from skills-lock.json
```

No Node.js, or does your client expect a plugin directory? Use
[manual install](#install-without-the-cli) instead.

## Install without the CLI

Use this path when Node.js is unavailable, the network is restricted, or a client wants a plugin
directory instead of loose skill folders.

### Copy a skill folder

Clone the repository or unpack a release archive, then copy the **whole skill folder** — not just
`SKILL.md` — to one of these locations:

| Scope | Location |
| --- | --- |
| Project | `<your project>/.agents/skills/<skill>/` |
| User | `~/.agents/skills/<skill>/` |

```bash
mkdir -p ~/.agents/skills
cp -R plugins/jade-apple/skills/jade-swiftdata ~/.agents/skills/
```

Copying `SKILL.md` alone breaks the reference links and scripts.

### Install a package as a plugin

A package is a portable plugin: `plugins/<package>/plugin.json` plus `plugins/<package>/skills/`.
Install the package directory, not one of its skill directories, when using a client that manages
plugins.

```bash
cp -R plugins/jade-project ~/my-plugins/jade-project
```

Client-specific plugin installation, enablement, and cache locations change between versions; use
the client's current documentation. This repository does not ship a marketplace index.

## Feedback

Open an issue for a bug, a confusing instruction, or a request for a new skill. Pull requests are
welcome; changes are reviewed and, when accepted, applied to the upstream development repository
and re-exported so the published content stays consistent. Contributor attribution is preserved.

## License

MIT — see [LICENSE](LICENSE). Copyright (c) Jade Zhou.
