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

## 用 npx 安装（推荐）

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

没有 Node.js，或客户端要求插件目录？改用[手动安装](#手动安装)。

## 手动安装

适用于没有 Node.js、网络受限，或客户端要求插件目录而非散装 skill 文件夹的情况。

### 复制 skill 文件夹

克隆仓库或解压 Release 压缩包，然后把**整个 skill 文件夹**（不只是 `SKILL.md`）复制到下列位置
之一：

| 范围 | 位置 |
| --- | --- |
| 项目级 | `<你的项目>/.agents/skills/<skill>/` |
| 用户级 | `~/.agents/skills/<skill>/` |

```bash
mkdir -p ~/.agents/skills
cp -R plugins/jade-apple/skills/jade-swiftdata ~/.agents/skills/
```

只复制 `SKILL.md` 会让参考链接和脚本失效。

### 作为客户端插件安装能力包

能力包就是一个便携式插件：`plugins/<package>/plugin.json` 加上 `plugins/<package>/skills/`。
使用带插件管理的客户端时，安装包目录本身，而不是包里的某个 skill 目录。

```bash
cp -R plugins/jade-project ~/my-plugins/jade-project
```

客户端的插件安装、启用与缓存位置会随版本变化，以该客户端当前文档为准。本仓库不提供
marketplace 索引。

## 反馈

发现问题、指令不清或需要新的 skill，请开 Issue。欢迎 Pull Request：改动会先审查，采纳后应用到上游
开发仓库再重新导出，以保证公开内容一致，并保留贡献者署名。

## 许可证

MIT，见 [LICENSE](LICENSE)。版权所有 (c) Jade Zhou。
