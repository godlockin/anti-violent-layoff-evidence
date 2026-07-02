# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- 销售岗子 skill
- 财务岗子 skill
- 英文 README
- 美国/香港/新加坡法域适配
- 律师/法律援助资源地图
- 移动端 App(本地优先)

## [1.0.0] - 2026-07-02

### Added
- **主 skill** (`SKILL.md`):
  - 顶层思维:三大不变量 + 证据金字塔 + 时间三段论
  - 五层布点架构(法律固证 → 第三方存证 → 个人镜像 → 雇主系统导出 → 现场留痕)
  - 50+ 条证据清单(物理位置/第三方平台/个人痕迹/同事互证/离职现场/雇主系统/暗证明)
  - 主动布点方案(入职第一天 + 每周 + 每月)
  - 60 秒应急包
  - 12 条红蓝对抗 Failover
  - 完整法律边界声明
- **工具脚本** (5 个):
  - `scripts/weekly-hash.sh` - 周五 30 秒自动 hash
  - `scripts/evidence-scanner.sh` - 扫描本地痕迹 (只读)
  - `scripts/evidence-collector.sh` - 选择性收集 + 加密打包
  - `scripts/evidence-aggregator.sh` - 汇总成 case-brief.md
  - `scripts/incident-tools.sh` - 60 秒应急工具
- **子 skill** (2 个):
  - `skills/developer/SKILL.md` - 程序员/测试/产品/DevOps/SRE/数据/算法/安全
  - `skills/general/SKILL.md` - 人事/行政/财务/销售/市场/运营/法务/教师/医护/公务员
- **模板**:
  - `templates/incident-runbook.md` - 60 秒应急 runbook
  - `evidence-checklist/manifest.csv.template` - hash 登记模板
- **开源文件**:
  - `README.md` - 中英双语
  - `LICENSE` - MIT + 免责声明
  - `CONTRIBUTING.md` - 贡献指南
  - `CODE_OF_CONDUCT.md` - 行为准则
  - `SECURITY.md` - 安全策略
  - `.gitignore`
  - `.github/ISSUE_TEMPLATE/` (bug_report, feature_request, legal_question)
  - `.github/workflows/ci.yml` - 脚本语法检查
  - `.github/PULL_REQUEST_TEMPLATE.md`

### Security
- 所有脚本默认 dry-run 或只读
- 加密压缩用 AES-256-GCM
- 个人信息不写入仓库
- 法律边界声明在 4 处明示(README/LICENSE/SKILL.md/scripts)

### Documentation
- 中英双语关键文件
- 法律引用标注具体法条
- 多角色视角覆盖(劳动法专家/律师/老油条/IT/调查记者/谈判/心理/联盟)

---

## 版本说明

- **MAJOR**:不兼容的破坏性变更
- **MINOR**:新增岗位 skill/工具(向后兼容)
- **PATCH**:文档/脚本/模板修复

---

**维护者**:@test-maintainer
