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

## [1.2.5] - 2026-07-02 — 🎯 收尾:功能完整 > 技术完备

### 项目定位
本项目是一个**暴力裁员的预防 skills**,从**思路、框架到具体执行和证据收集、固定**,
功能完整 > 技术完备。

- **覆盖场景**:被暴力裁员、锁 SSO/电脑/物理清退,劳动者仍能证明工作内容/时间/强度/成果
- **覆盖岗位**:全员通用基础层 + 程序员/测试/产品/DevOps 角色层
- **覆盖证据**:50+ 条证据维度(邮件、审批、沟通、纸面、财务、git、监控、值班、位置、节假日)
- **覆盖法域**:中国大陆(主)+ 香港/新加坡/美国(法条引用)
- **覆盖用户**:`./skills/general/SKILL.md` 适用任何人,`./skills/developer/SKILL.md` 适用技术岗

### 设计哲学
- **事前预防** > 事后补救
- **独立存储** > 依赖雇主系统
- **多维冗余** > 单点证据
- **可信可采** > 形式堆砌
- **多角色视角**:劳动法专家 / 律师 / 老油条 / 调查记者 / 谈判专家 / 心理咨询师 / 集体行动者
- **三层架构**:基础层(全员) + 角色层(程序员) + 汇总层(律师面谈前)

### 新增
- `scripts/avle-launcher.sh` — **6 步引导式主入口**(欢迎 → 邮箱 → 公司 → 目录 → 模块 → 扫描 → 报告)
- `scripts/rust-accel.sh` — rust 工具加速器(fd / eza / rg / bat / delta / dust / procs / zoxide / sd / xh / hyperfine),自动探测 + fallback
- `scripts/git-evidence-scanner.sh --account-report` — 账号分析(COMPANY vs PERSONAL vs EDU),自动识别公司 vs 个人 commit
- `scripts/storage-evidence-scanner.sh` — **多存储扫描**(16 个云盘 + 移动硬盘),扩展到 macOS `/Volumes/` 和 Linux `/media` / `/mnt`
- `scripts/holiday-sync.sh` — 法定节假日(2024-2026)+ 调休标记 + 工作日计算
- `scripts/location-worklog.sh` — WFH / 客户现场 / 出差位置记录(支持 WiFi 自动探测)
- `scripts/unify-summarize.sh` — **统一汇总 → case-brief.md**,动态 checklist + 证据缺口分析
- `scripts/evidence-collector.sh` / `evidence-aggregator.sh` — 收集 + 基础汇总
- `scripts/incident-tools.sh` — 60 秒应急工具
- `scripts/lib/config.sh` — 用户配置 + 自动探测 `~/.config/avle.conf`
- `scripts/lib/assoc-array.sh` — macOS bash 3.2 关联数组 polyfill
- `tests/` — UT/IT 框架(框架提交,本机数据 `.gitignore`)

### 改进
- **macOS bash 3.2 兼容**:`declare -A` → 文件模拟/变量,4 个脚本修复
- **detect_my_emails**:
  - 深度 4 → 8(覆盖 JetBrains settingsSync)
  - 多源探测(5 源:全局 gitconfig + .gitconfig + 8 层 .git 目录 + git log 历史 + 显式 IDE 位置)
  - 智能过滤(noreply / localhost / IP / 罕见)
- **git-evidence 加账号分析**:`account_group` + `is_mine` 两列,基于 `~/.config/avle.conf` 过滤用户 commit
- **case-brief 动态 checklist**:根据实际 manifest 自动勾选 `[x]` / `[~]` / `[]`
- **case-brief 证据缺口分析**:根据 git 占比 < 5% 提示"非程序员,改用 general 证据"
- **storage-scanner 集成 rust 加速**:有 fd/rg 自动用,无则 fallback bash

### 修复
- 5 个脚本在 macOS bash 3.2 下因 `declare -A` 报错(已全修复)
- git log `--pretty=format:%ae\n%ce` 输出字面 `\n` 字符串(改 `tformat`)
- 4 个脚本缺 macOS bash 3.2 兼容 polyfill
- detect_my_emails 漏检公司邮箱(深度不够 + 没扫 git log 历史)

### 隐私保护
- **v1.2.3**:10 个开源文件去除所有指向性内容(IKEA / steven / godlockin / miao → `@test` 占位符)
- **v1.2.4**:`git filter-repo` 改写 9 个 commit,远程已 force push,GitHub 上**没有任何指向性历史**
- **v1.2.5**:detect_my_emails 智能过滤,本机数据 `.gitignore` 隔离,tests/output/ 框架 + `.gitkeep` 而非数据

### 性能
- **fd 替代 find**:`~` 4 层 *.png 扫描 1.24s → 0.08s(15.5x 加速)
- **rg 替代 grep**:基准 5-20x 加速(实测看具体场景)
- **eza / bat / delta / dust / procs** 自动 fallback

### 已知边界
- macOS bash 3.2 兼容:用文件模拟关联数组,略慢但稳定
- 节假日数据硬编码 2024-2026,2027+ 需更新(每年 11-12 月国办公布)
- 16 个云盘扫描只扫已挂载的目录(需客户端登录)
- rust 加速器需要工具已安装(自动探测,无则 fallback)
- 本机 evidence 数据靠 `.gitignore` 隔离,误 commit 可能泄漏(谨慎)

### 后续
- v1.3+:更多岗位子 skill(销售/财务/法务/医护/教师/公务员)
- v1.3+:美/港/新/英/德法域适配
- v1.3+:UT 单元测试 + IT 集成测试
- v2.0:跨法域仲裁模板 + 移动端 App + 工会集体行动案例库

### 致谢
- 中国法律服务网 (`12348.gov.cn`)
- 12333 劳动维权热线
- 权利卫士 / 至信链(区块链存证)
- 联合信任时间戳(TSA)
- 维护者本机实测 + 查漏补缺(本机数据归档到 `tests/output/`,**不入开源仓库**)

### 维护
- **维护者**:`@test-maintainer`
- **当前版本**:`v1.2.5`
- **状态**:功能完整,可作为个人证据保留工具使用
- **设计原则**:**功能完整 > 技术完备**(出问题时简单能跑 > 复杂不能用)

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

**维护者 / Maintained by**: `@test-maintainer`
