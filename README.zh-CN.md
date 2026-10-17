[English](README.md) · 简体中文

# Jade Agent Skills

面向 AI 编程 Agent 的可移植 skill：React 性能排查、Apple 平台开发、项目文档结构。每个 skill 都是
自带触发条件、步骤和参考资料的独立工作流——只安装你需要的部分。

## 包含内容

三个能力包，各自独立版本。能力包（package）是安装与版本管理单位，skill 是最小安装单位。

| 能力包 | Skill | 作用 |
| --- | --- | --- |
| `jade-react` | `jade-react-performance` | 诊断并改进 React 的加载、请求瀑布、交互延迟与重复渲染；含按需启用的 Next.js/RSC 说明 |
| `jade-apple` | `jade-swiftdata` | 实现、排查或审查 SwiftData 的模型、查询、保存、并发与 schema 迁移 |
| `jade-apple` | `jade-swift-concurrency` | 实现、排查或审查 actor 隔离、`Sendable` 诊断、任务取消、回调转 async 与 Swift 6 迁移 |
| `jade-apple` | `jade-custom-control-center-icons` | 为 iOS 18+ 制作控制中心自制符号，并排查空白或问号图标，含 `actool`/`assetutil` 验证 |
| `jade-project` | `jade-design-maintained-project-docs` | 为持续维护的项目设计、建立或调整文档结构 |
| `jade-project` | `jade-design-lightweight-project-docs` | 为小型库、工具和原型建立最小文档结构 |
| `jade-project` | `jade-maintain-dev-docs` | 治理开发文档：变更记录、架构同步、决策、交接与历史迁移 |

每个 skill 都尊重它所在项目已有的约定。它们不需要本仓库中的其他 skill，也不依赖自身目录之外的
文件。

## 用 npx 安装

```bash
# 查看全部七个 skill
npx skills add jadezhouu/jade-agent-skills-public --list

# 安装单个
npx skills add jadezhouu/jade-agent-skills-public --skill jade-swiftdata -a codex -y

# 安装多个
npx skills add jadezhouu/jade-agent-skills-public --skill jade-swiftdata \
  --skill jade-maintain-dev-docs -a codex -y

# 安装全部七个
npx skills add jadezhouu/jade-agent-skills-public --skill '*' -a codex -y
```

使用第三方 [`skills`](https://www.npmjs.com/package/skills) 命令行工具（实测版本 1.7.2），要求
**Node.js >= 22.20.0**。它会把选中的 skill 复制到 `.agents/skills/`（项目级）或客户端要求的目录，
在 `skills-lock.json` 里记录来源与内容哈希；访问本公开仓库不需要任何凭据。

- 默认项目级安装，加 `-g` 才是用户级。
- 没有终端交互时必须带 `-y`；`--copy` 强制复制。
- 交互式选择与 symlink 方式**未验证**；已验证的是非交互、复制模式：安装后的文件路径、内容与
  随包脚本的 `0755` 权限与本仓库逐字节一致，且不创建符号链接。

更新与恢复：

```bash
npx skills update jade-swiftdata -y -p     # 按记录来源重新拉取
npx skills experimental_install            # 按 skills-lock.json 恢复记录的内容
```

## 安装单个 skill

1. 取得仓库内容（克隆仓库，或下载 Release 压缩包并解压）。
2. 把**整个 skill 文件夹**（不只是 `SKILL.md`）复制到下列位置之一：

   | 范围 | 位置 |
   | --- | --- |
   | 项目级 | `<你的项目>/.agents/skills/<skill>/` |
   | 用户级 | `~/.agents/skills/<skill>/` |

   例如，在克隆后的仓库根目录执行：

   ```bash
   mkdir -p ~/.agents/skills
   cp -R plugins/jade-apple/skills/jade-swiftdata ~/.agents/skills/
   ```

3. 确认复制后的目录里有 `SKILL.md`，以及随它提供的 `references/`、`assets/`、`scripts/`。只复制
   `SKILL.md` 会让参考链接和脚本失效。

## 安装整个能力包

能力包就是一个便携式插件：`plugins/<package>/plugin.json` 加上 `plugins/<package>/skills/`。
使用带插件管理的客户端时，安装包目录本身，而不是包里的某个 skill 目录。

```bash
cp -R plugins/jade-project ~/my-plugins/jade-project
```

客户端的插件安装、启用与缓存位置会随版本变化，以该客户端当前文档为准。本仓库不提供
marketplace 索引。

## 版本与固定

每个能力包独立版本，各自打标签发布。当前已发布
[jade-apple 0.1.1](https://github.com/jadezhouu/jade-agent-skills-public/releases/tag/jade-apple-v0.1.1)、
[jade-react 0.1.1](https://github.com/jadezhouu/jade-agent-skills-public/releases/tag/jade-react-v0.1.1)、
[jade-project 0.1.1](https://github.com/jadezhouu/jade-agent-skills-public/releases/tag/jade-project-v0.1.1)。

从本仓库安装默认跟随主分支；用标签路径可以固定版本：

```bash
npx skills add https://github.com/jadezhouu/jade-agent-skills-public/tree/jade-apple-v0.1.1/plugins/jade-apple/skills/jade-swiftdata -a codex -y
```

`tree/<提交号>` **不可用**：安装器会把这一段当成分支名，克隆会失败。请使用标签或分支。

每个版本的发布压缩包内含 `plugin.json`、`skills/`、`LICENSE` 与 `PACKAGE-MANIFEST.json`，并附带
`.sha256` 文件与合并的 `SHA256SUMS`：

```bash
shasum -a 256 -c jade-apple-0.1.1.zip.sha256
unzip jade-apple-0.1.1.zip -d jade-apple
```

`PACKAGE-MANIFEST.json` 列出每个文件的 SHA-256 与权限位，可以逐个文件核对解压结果；其中的
`git_commit` 记录上游开发仓库的构建提交，仅作追溯，安装与校验都用不到它。已发布的压缩包都经过匿名下载、校验和验证与
实际安装。`skills-lock.json` 配合 `npx skills experimental_install` 可以在不下载压缩包的情况下恢复
已安装的确切内容。

## 兼容性

| 安装方式 | 状态 |
| --- | --- |
| `npx skills add`（1.7.2） | 已验证：列出全部七个 skill、单个/多选/全部的项目级安装、更新、按锁定文件恢复 |
| 从克隆手动复制 | 已验证 |
| 把包目录当插件安装 | 已在 Codex CLI 上用本地 marketplace 验证；本仓库不提供 marketplace 索引 |
| 发布压缩包 | 已验证：匿名下载、校验和验证、从发布地址安装 |

| 客户端 | 状态 |
| --- | --- |
| Codex CLI 0.154.0 | 已验证：安装、skill 发现与任务执行 |
| DeepSeek Harness（`dsh headless`） | 已验证：项目级 `.agents/skills/` 发现与任务执行 |
| Claude Code | 未验证 |
| 其他客户端 | 未验证 |

这些 skill 遵循 `SKILL.md` 约定：YAML frontmatter 提供 `name` 与 `description`，正文为 Markdown
指令，可选 `references/`、`assets/`、`scripts/` 目录。读取该约定的客户端可以加载它们，但"文件格式
相同"不等于"在该客户端里行为正确"——上表未列出的客户端均未测试。

平台说明：Apple 相关 skill 针对 macOS、iOS、watchOS 工作流验证，涉及构建或资源编译时会假定有可用的
Xcode 工具链。本仓库未在真机上验证，也未覆盖每个系统版本。

## 反馈

发现问题、指令不清或需要新的 skill，请开 Issue。欢迎 Pull Request：改动会先审查，采纳后应用到上游
开发仓库再重新导出，以保证公开内容一致，并保留贡献者署名。

## 许可证

MIT，见 [LICENSE](LICENSE)。版权所有 (c) Jade Zhou。
