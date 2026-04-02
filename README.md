# FullStack-Crew

VS Code Copilot 多 Agent 协作团队 — 用 `.agent.md` 文件定义 7 个专业角色，由 Orchestrator 编排协作，端到端交付项目。

## 架构

```
                    ┌─────────────────┐
                    │  orchestrator   │  编排者（Hub）
                    └────────┬────────┘
      ┌────────┬───────┼───────────┬──────────┬──────────┐
      ▼        ▼       ▼           ▼          ▼          ▼
  ┌──────┐ ┌───────┐ ┌─────────────┐ ┌──────────┐ ┌──────────┐ ┌────────┐
  │  pm  │ │ arch  │ │ implementer │ │ verifier │ │ deployer │ │reviewer│
  └──────┘ └───────┘ └─────────────┘ └──────────┘ └──────────┘ └────────┘
   产品经理  架构师    实现者       验证者       部署者    审查员(备选)
```

Orchestrator 支持**自递归** — 当任务涉及多个独立子模块时，可委派子 orchestrator 各自跑完整闭环。

## Agent 概览

| 文件 | 角色 | 职责 | 工具 |
|------|------|------|------|
| `orchestrator.agent.md` | Orchestrator | 任务分解、委派编排、质量门禁、交付报告 | agent, todo, read, edit, search, vscode/memory, argus/* |
| `pm.agent.md` | Product Manager | 市场调研、竞品分析、PRD、用户故事 | read, edit, search, web, vscode/memory |
| `architect.agent.md` | System Architect | 系统设计、技术选型、数据建模、API 设计 | read, edit, search, web, vscode/memory |
| `implementer.agent.md` | Implementer | 实现、重构、Bug 修复、迭代修改 | read, edit, search, execute, vscode/memory |
| `verifier.agent.md` | Verifier | 验证策略、用例编写、覆盖率分析、缺陷诊断 | read, edit, search, execute, vscode/memory |
| `deployer.agent.md` | Deployer | 容器化、CI/CD、部署配置、监控 | read, edit, search, execute, vscode/memory |
| `reviewer.agent.md` | Code Reviewer | 代码质量审查、架构一致性检查、安全反模式检测 | read, search, vscode/memory |

## 工作流程

```
Phase 1 — Planning    → PM 调研 + Architect 设计
Phase 2 — Implementation → Implementer 编码
Phase 3 — Quality Gate   → Code Review (Argus/Self) + Verifier 测试（最多 3 轮迭代）
Phase 4 — Delivery       → Deployer 部署 + 交付报告
```

## 特性

- **自学习协议**: 每个 Agent 具备三步学习机制 — 启动加载知识 → 角色反思 → 记录学习
- **双轨知识存储**: 通用知识（`/memories/<role>.md`）+ 项目知识（`.github/learnings/<role>.md`）
- **角色自进化**: Agent 可基于任务反思直接修改自身定义文件
- **Argus 降级**: 质量门禁支持 Argus MCP 自动评审，不可用时自动回退到 Self-review
- **自递归**: Orchestrator 可委派子 Orchestrator 处理独立子模块

## 安装

将所有 `.agent.md` 文件复制到以下位置之一：

| 范围 | 路径 |
|------|------|
| 用户级（所有项目生效） | `%APPDATA%\Code\User\prompts\` (Windows) 或 `~/.config/Code/User/prompts/` (macOS/Linux) |
| 项目级（仅当前仓库） | `.github/prompts/` |

## 使用

在 VS Code Copilot Chat 中调用：

```
@orchestrator 实现一个用户登录功能
@orchestrator review 当前项目
@orchestrator 修复 issue #42
```

也可以直接调用子 Agent：

```
@implementer 重构这个函数
@verifier 为 auth 模块写测试
@architect 设计消息队列方案
```

## AI 加速倍率

| 任务类型 | 传统耗时 | AI 辅助耗时 | 加速倍率 |
|---------|---------|-----------|---------|
| 样板代码生成 | 2h | 2min | ~60x |
| 测试用例编写 | 4h | 15min | ~16x |
| 代码审查 | 1h | 5min | ~12x |
| Bug 根因分析 | 3h | 20min | ~9x |
| 架构设计 | 8h | 2h | ~4x |
| 需求分析 | 4h | 1.5h | ~3x |

## 依赖

- **必需**: VS Code + GitHub Copilot Chat (Agent Mode)
- **可选**: [Argus MCP Server](https://github.com/argus-project/argus) — 自动代码评审（不可用时自动降级）

## License

MIT
