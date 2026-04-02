# FullStack-Crew 设计哲学

## Hub-Spoke 架构

Tech Lead 作为唯一编排者（Hub），所有子 Agent 只与 Tech Lead 交互（Spoke）。
- **为什么不用 Mesh**: Agent 间直接通信会导致职责混乱和无限递归
- **为什么不用 Pipeline**: 不是所有任务都需要经过全部 Agent
- **自递归例外**: Tech Lead 可委派子 Tech Lead 处理独立子模块

## 完备性原则 (Boil the Lake)

> AI 时代完整性的边际成本趋近于零。

- 不留 TODO、不写 stub、不做"先凑合后优化"
- 第一次就做到位，异常路径与正常路径同等重要
- 搜索优先：项目内 → 社区方案 → 从零设计

## 质量门禁而非信任机制

- 不信任任何单个 Agent 的输出 — 总有另一个 Agent 审查
- Implementer 实现 → Reviewer/Argus 审查 → Verifier 验证 → Implementer 修复 → 迭代
- WTF 计数器防止修复循环失控

## 自学习与自进化

- 每个 Agent 在任务完成后反思并记录学到的知识
- 通用知识跨项目持久化，项目知识随仓库存储
- Agent 可修改自身定义文件 — 真正的自我进化

## 搜索优先 (Search Before Building)

三层知识搜索：
1. **Tried-and-true**: 项目内已有方案
2. **New-and-popular**: 社区主流方案
3. **First-principles**: 从零设计（最后手段）

## AI 加速倍率参考

| 任务类型 | 传统耗时 | AI 辅助耗时 | 加速倍率 |
|---------|---------|-----------|---------|
| 样板代码生成 | 2h | 2min | ~60x |
| 测试用例编写 | 4h | 15min | ~16x |
| 代码审查 | 1h | 5min | ~12x |
| Bug 根因分析 | 3h | 20min | ~9x |
| 架构设计 | 8h | 2h | ~4x |
| 需求分析 | 4h | 1.5h | ~3x |
