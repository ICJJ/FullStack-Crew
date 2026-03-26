# 贡献指南

## 添加新 Agent

1. 在 `prompts/` 根目录创建 `<name>.agent.md`（**不要**放子目录，VS Code 不识别）
2. 包含 YAML frontmatter：`description`, `tools`, `user-invocable`
3. 必须包含章节：Core Responsibilities, Constraints, Self-Learning Protocol
4. 在 `tech-lead.agent.md` 的 `agents:` 列表和 Sub-Agents 表中注册新 Agent
5. 更新 `README.md` 的 Agent 概览表
6. 运行 `.\validate-agents.ps1` 确认通过

## 修改现有 Agent

- Agent 可通过自学习协议自我修改（仅修改自身文件）
- 人工修改时遵循以下规则：
  - 每次最多修改 1-2 个章节
  - 保持 YAML frontmatter 格式正确
  - 确保 Completion Status Protocol 存在
  - 修改后运行 `.\validate-agents.ps1`

## 知识文件格式

### 通用知识 (`/memories/<role>.md`)
- 跨项目持久化，存储在 VS Code 用户级存储中
- 由 Agent 自动维护，不建议手动编辑

### 项目知识 (`.github/learnings/<role>.md`)
- 仓库级存储，可 git 提交
- 由 Agent 自动创建和更新

## 版本管理

- 修改 Agent 后更新 `CHANGELOG.md`（Added/Changed/Removed）
- 版本号遵循 SemVer：
  - **Major**: 架构变更（如 Agent 间协议变化）
  - **Minor**: 新增 Agent 或重要能力
  - **Patch**: Bug 修复、文档更新、微调

## 验证

```bash
# 运行 Agent 健康检查
.\validate-agents.ps1
```
