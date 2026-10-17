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

## Install with npx

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

## Install a single skill

1. Get the repository contents (clone, or download a release archive and unpack it).
2. Copy the **whole skill folder** — not just `SKILL.md` — into one of these locations:

   | Scope | Location |
   | --- | --- |
   | Project | `<your project>/.agents/skills/<skill>/` |
   | User | `~/.agents/skills/<skill>/` |

   For example, from a clone of this repository:

   ```bash
   mkdir -p ~/.agents/skills
   cp -R plugins/jade-apple/skills/jade-swiftdata ~/.agents/skills/
   ```

3. Confirm the copied folder contains `SKILL.md` plus any `references/`, `assets/`, and `scripts/`
   that ship with it. Copying `SKILL.md` alone breaks the reference links and scripts.

## Install a whole package

A package is a portable plugin: `plugins/<package>/plugin.json` plus `plugins/<package>/skills/`.
Install the package directory, not one of its skill directories, when using a client that manages
plugins.

```bash
cp -R plugins/jade-project ~/my-plugins/jade-project
```

Client-specific plugin installation, enablement, and cache locations change between versions; use
the client's current documentation. This repository does not ship a marketplace index.

## Versions and pinning

Each package is versioned independently (`jade-react-v0.1.x`, `jade-apple-v0.1.x`,
`jade-project-v0.1.x`). Installs from this repository follow the default branch; pin a version by
installing from its tag path once that version is tagged:

```bash
npx skills add https://github.com/jadezhouu/jade-agent-skills-public/tree/jade-apple-v0.1.1/plugins/jade-apple/skills/jade-swiftdata -a codex -y
```

`tree/<commit-sha>` does **not** work: the installer treats that path segment as a branch name, and
the clone fails. Use a tag or a branch.

When a version is released, its release archive contains `plugin.json`, `skills/`, `LICENSE`, and
`PACKAGE-MANIFEST.json`, together with a `.sha256` file and a combined `SHA256SUMS`:

```bash
shasum -a 256 -c jade-apple-0.1.1.zip.sha256
unzip jade-apple-0.1.1.zip -d jade-apple
```

`PACKAGE-MANIFEST.json` lists every file with its SHA-256 and mode, so the unpacked content can be
verified file by file. Its `git_commit` field records the build commit in the upstream development
repository; it is informational and not needed to install or verify a package. Without a release
archive, `skills-lock.json` plus `npx skills experimental_install` restores the exact installed
content.

## Compatibility

| Install path | Status |
| --- | --- |
| `npx skills add` (1.7.2) | Verified: lists all seven skills, single/multi/all project installs, update, lock restore |
| Manual copy from a clone | Verified |
| Package directory as a plugin | Verified with Codex CLI against a local marketplace; this repository does not ship a marketplace index |
| Release ZIP | Not yet available |

| Client | Status |
| --- | --- |
| Codex CLI 0.154.0 | Verified: install, skill discovery, and task execution |
| DeepSeek Harness (`dsh headless`) | Verified: project-level `.agents/skills/` discovery and task execution |
| Claude Code | Not yet verified |
| Other clients | Not yet verified |

Skills follow the `SKILL.md` convention: YAML frontmatter with `name` and `description`, Markdown
instructions, and optional `references/`, `assets/`, and `scripts/` folders. Clients that read that
convention can load them, but "same file format" is not the same as "behaves correctly in that
client" — anything not listed above is untested.

Platform notes: the Apple skills are validated for macOS, iOS, and watchOS workflows and assume a
current Xcode toolchain when they mention building or asset compilation. Nothing here has been
verified on a physical device or against every OS version.

## Feedback

Open an issue for a bug, a confusing instruction, or a request for a new skill. Pull requests are
welcome; changes are reviewed and, when accepted, applied to the upstream development repository
and re-exported so the published content stays consistent. Contributor attribution is preserved.

## License

MIT — see [LICENSE](LICENSE). Copyright (c) Jade Zhou.
