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

## Releases and checksums

Each package has its own version tag (`jade-react-v0.1.x`, `jade-apple-v0.1.x`,
`jade-project-v0.1.x`) and release archive containing `plugin.json`, `skills/`, `LICENSE`, and
`PACKAGE-MANIFEST.json`, plus a `.sha256` file and a combined `SHA256SUMS`.

```bash
shasum -a 256 -c jade-apple-0.1.1.zip.sha256
unzip jade-apple-0.1.1.zip -d jade-apple
```

`PACKAGE-MANIFEST.json` lists every file in the archive with its SHA-256 and file mode, so you can
verify the unpacked content file by file. The `git_commit` field in that manifest records the
commit the archive was built from in the upstream development repository; it is informational and
is not needed to install or verify a package.

A tag fixes the repository snapshot for that release. Install a specific version by tag when you
need a pinned copy:

```bash
git clone --branch jade-apple-v0.1.1 https://github.com/jadezhouu/jade-agent-skills-public.git
```

## Compatibility

| Client | Status |
| --- | --- |
| Codex CLI 0.154.0 | Verified: package install, skill discovery, and task execution |
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
