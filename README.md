<div align="center">

# 🛡️ Anti-Violent-Layoff Evidence (AVLE) / 反暴力裁员证据链

> **在雇主单方面锁号、关电脑、收缴 U 盾、物理清退时,劳动者仍能证明工作内容、时间、地点、强度、成果,并据此索取应得赔偿。**
>
> **Defensive skill collection for workers facing sudden account lockouts, computer seizure, and violent dismissal.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Skills: 2](https://img.shields.io/badge/skills-developer%20%2B%20general-green.svg)](skills/)
[![Scripts: 11](https://img.shields.io/badge/scripts-11-blue.svg)](scripts/)
[![Jurisdiction: CN](https://img.shields.io/badge/jurisdiction-CN%20%7C%20HK%20%7C%20SG%20%7C%20US-lightgrey.svg)](#-适用法律体系--jurisdictions)
[![Version: v1.2.0](https://img.shields.io/badge/version-v1.2.0-orange.svg)](CHANGELOG.md)
[![Tested on macOS](https://img.shields.io/badge/tested-macOS%2026.5.1-blue.svg)](#-测试--testing)
[![bash 3.2+](https://img.shields.io/badge/bash-3.2%2B%20%7C%205.x-green.svg)](CONTRIBUTING.md)

[English](#-english) | [中文](#-中文)

</div>

---

## ⚠️ 法律声明 / Legal Notice

> **本仓库仅整理证据保留方法,不构成法律意见,不教唆对抗、伪造、报复或侵犯商业秘密。具体案件请咨询执业律师。**
>
> **This repository provides evidence-preservation methods only, not legal advice. Do not use for retaliation, evidence fabrication, or trade-secret theft. Consult a licensed attorney for your case.**

| 合法用途 (Lawful uses) ✅ | 禁止行为 (Prohibited) ❌ |
|------------------------|------------------------|
| 完整保留属于你的工作产物副本 | 偷窃商业秘密、客户名单 |
| 主张自身合法权益(N、N+1、2N、加班费) | 报复性删库、勒索、骚扰 |
| 走劳动监察、仲裁、诉讼 | 删除公司合法资产 |
| 用公开合法渠道监督雇主 | 伪造证据 |
| 推动职场透明化 | 以曝光要挟敲诈勒索 |

---

# 🇨🇳 中文

## 🎯 核心目标 / Mission

在以下三种攻击面下保住证据:

| # | 攻击面 | 雇主动作 | 我们反制 |
|---|--------|---------|---------|
| **I1 数字锁死** | SSO/SaaS/云盘 | 锁号、删数据、清云盘 | 镜像推个人云 + GitHub |
| **I2 物理剥夺** | 电脑、U 盾、工牌 | 收缴、收门禁、扣物品 | 物理证据位 + 同事互证 |
| **I3 否认** | 工作内容、时间、强度 | "他没做过" / "工作时间不饱和" | 多源时戳证据 + 第三方存证 |

## 🧠 核心方法论

### 证据金字塔 (Evidence Pyramid)
```
                    ┌──── 顶层 ────┐
                    │ 公证处存证   │ 可信度 ★★★★★
                    ├──── 强证据 ──┤
                    │ 第三方平台   │ (权利卫士 / 至信链)
                    │   时间戳证据 │
                    ├──── 主证据 ──┤
                    │ 雇主系统导出 │ (来自企业 SaaS)
                    │ (邮件/工单)  │ 真实性可质证
                    ├──── 辅证据 ──┤
                    │ 截图/录屏    │ ⚠ 必须多源印证
                    │ 自存笔记     │
                    ├──── 兜底 ────┤
                    │ 当事人陈述   │ 自述证据,效力最低
                    └─────────────┘
```
**关键原则**:永远不只存一种。任何证据单独看都可能"瑕疵",但 3 个以上独立渠道交叉印证 → 法官/仲裁员会认定"高度盖然性"标准(民诉法 §108)。

### 时间三段论
| 段 | 时间窗 | 心态 | 重点 |
|----|--------|------|------|
| **黄金预防期** | 入职 → 收到裁员风声 | 主动 | 大规模布点 |
| **黄金取证期** | 接到通知 → 锁号(24-72h) | 紧张 | 全维度导出 + 镜像备份 |
| **救济期** | 锁号后 → 仲裁 1 年时效 | 理性 | 公证 / 区块链固证 / 律师 |

### 三大不变量 (Invariants)
| # | 不变量 | 攻击方诉求 | 防御方反制 |
|---|--------|-----------|-----------|
| I1 | **事实可还原** | "他没做过" | 多源时戳证据 |
| I2 | **身份可识别** | "这是他私人行为" | 域名+工号+岗位职责匹配 |
| I3 | **链条可验证** | "证据后期伪造" | hash + 时间戳 + 第三方存证 |

## 📦 仓库结构

```
anti-violent-layoff-evidence/
├── README.md                          ← 你在这里
├── LICENSE                            ← MIT + 免责声明
├── CONTRIBUTING.md                    ← 贡献指南
├── CHANGELOG.md                       ← 变更日志
├── SECURITY.md                        ← 安全策略
├── CODE_OF_CONDUCT.md                 ← 行为准则
│
├── SKILL.md                           ← 主 skill (顶层思维 + 证据清单)
│
├── scripts/                           ← 可执行工具
│   ├── weekly-hash.sh                 ← 周维护 (30 秒)
│   ├── evidence-scanner.sh            ← 扫描本地痕迹 (只读)
│   ├── evidence-collector.sh          ← 选择性收集 + 加密打包
│   ├── evidence-aggregator.sh         ← 生成 case-brief.md
│   ├── storage-evidence-scanner.sh    ← [基础层] 多存储扫描 (16 网盘 + 移动硬盘)
│   ├── location-worklog.sh            ← [基础层] 位置记录 (WFH/客户现场/出差)
│   ├── holiday-sync.sh                ← [基础层] 法定节假日 (2024-2026 + 调休)
│   ├── git-evidence-scanner.sh        ← [角色层] 程序员 git commit 遍历
│   ├── unify-summarize.sh             ← [汇总层] 统一汇总 → case-brief.md
│   └── incident-tools.sh              ← 60 秒应急工具
│
├── templates/                         ← 模板
│   ├── incident-runbook.md            ← 事发当日 runbook
│   └── ... (更多)
│
├── evidence-checklist/                ← 证据分清单
│   └── manifest.csv.template
│
└── skills/                            ← 子 skill (按岗位分类)
    ├── general/SKILL.md               ← [基础层] 通用岗 (HR/行政/财务/...)
    └── developer/SKILL.md             ← [角色层] 程序员/测试/产品/devops
```

## 🏛️ 三层架构 / Three-Layer Architecture

> **核心设计**:所有岗位先用 **[基础层 general](./skills/general/SKILL.md)** → 按岗位叠加 **[角色层 developer/...](./skills/developer/SKILL.md)** → 律师面谈前跑 **[汇总层 unify-summarize.sh](./scripts/unify-summarize.sh)** 出 case-brief.md
>
> **Core Design**:All roles start with **[General Base](./skills/general/SKILL.md)** → add role-specific layer → aggregate via **[Unified Summarizer](./scripts/unify-summarize.sh)** before lawyer meeting.

```
┌────────────────────────────────────────────────────────────┐
│  Layer 3 汇总层 / Aggregation                             │
│  scripts/unify-summarize.sh → case-brief.md               │
├────────────────────────────────────────────────────────────┤
│  Layer 2 角色层 / Role-Specific(按岗位叠加)              │
│  skills/developer/SKILL.md (程序员/测试/产品/DevOps)     │
│  skills/general/SKILL.md   (全员通用基础层,适合非程序员) │
├────────────────────────────────────────────────────────────┤
│  Layer 1 基础层 / General Base(全员必跑)                  │
│  storage-scan / location-log / holiday-sync / weekly-hash │
└────────────────────────────────────────────────────────────┘
```

## 🚀 快速开始

### 🌟 推荐:用引导式 launcher(6 步)

```bash
bash scripts/avle-launcher.sh
```

交互流程:
1. 📧 配置 git 邮箱(自动探测 + 确认)
2. 🏢 配置公司域名
3. 📂 配置扫描目录(默认)
4. ⚙️  启用/禁用 6 个模块
5. 🚀 开始全盘扫描(显示进度)
6. ✅ 输出 checklist + 证据包路径

**其他模式**:
```bash
bash scripts/avle-launcher.sh --quick     # 快速模式:跳过问询,全默认
bash scripts/avle-launcher.sh --resume    # 跳过引导,直接跑(用已有配置)
bash scripts/avle-launcher.sh --config    # 只配置,不扫描
bash scripts/avle-launcher.sh --dry-run   # 显示将要执行什么
```

### Step 0 — 一次性 setup

```bash
# 1) 克隆
git clone https://github.com/your-org/anti-violent-layoff-evidence.git
cd anti-violent-layoff-evidence

# 2) 建立证据目录
mkdir -p ~/evidence/{periodic,incident,timestamp,notarized}

# 3) 配置个人云同步(不要用公司云盘)
# ✅ 推荐:坚果云 / 百度网盘 / OneDrive 个人版 / iCloud / Google Drive
# ❌ 不要用:公司提供的云盘、公司配的 NAS、公司域账号下的任何 SaaS

# 4) 设置周维护 cron (每周五 18:00)
echo "0 18 * * 5 bash $(pwd)/scripts/weekly-hash.sh" | crontab -
```

### Step 1 — 先读基础层(全员必读)

> 📖 [`skills/general/SKILL.md`](skills/general/SKILL.md) — 邮件/审批/沟通/纸面/财务/位置/节假日,**任何岗位都适用**

### Step 2 — 按岗位叠加角色层

| 你是谁 / You are | 读这个 / Read |
|------------------|--------------|
| 程序员/测试/产品/DevOps/算法/数据/安全 / Developer, QA, PM, DevOps, Algo, Data, Security | [`skills/developer/SKILL.md`](skills/developer/SKILL.md) |
| 其他岗位 / Others(HR/行政/财务/销售/教师/医护/公务员/...) | 不需要角色层,基础层就够 |

### Step 3 — 日常维护(预防期)

```bash
# 每周五 18:00 自动跑(已设 cron)
bash scripts/weekly-hash.sh

# 手动跑可选:
bash scripts/storage-evidence-scanner.sh   # 每月:全盘扫描
bash scripts/location-worklog.sh --auto   # 每天 9/13/18:位置打卡
bash scripts/holiday-sync.sh              # 每年 12 月:更新明年节假日
```

### Step 4 — 事发当日(60 秒)

```bash
cat templates/incident-runbook.md         # 应急 runbook
bash scripts/incident-tools.sh            # 60 秒应急工具
bash scripts/evidence-collector.sh --apply  # 加密打包所有证据
```

### Step 5 — 律师面谈前(汇总)

```bash
# 一键汇总全部 evidence
bash scripts/unify-summarize.sh

# 一键汇总 + 加密打包
bash scripts/unify-summarize.sh --package
```

## 🛠️ 工具速查(按层分类)

### Layer 1 — 基础层工具(全员)
| 脚本 | 用途 | 何时跑 |
|------|------|--------|
| [`scripts/weekly-hash.sh`](scripts/weekly-hash.sh) | 周维护 hash 登记 | 每周五(预防) |
| [`scripts/storage-evidence-scanner.sh`](scripts/storage-evidence-scanner.sh) | **全磁盘 + 16 网盘 + 移动硬盘扫描** | 每月 |
| [`scripts/location-worklog.sh`](scripts/location-worklog.sh) | **位置记录 (WFH/客户/出差)** | 每天 9/13/18 |
| [`scripts/holiday-sync.sh`](scripts/holiday-sync.sh) | **法定节假日 + 调休 (2024-2026)** | 每年 12 月 |
| [`scripts/evidence-scanner.sh`](scripts/evidence-scanner.sh) | 扫描本地痕迹(只读) | 准备期 |
| [`scripts/evidence-collector.sh`](scripts/evidence-collector.sh) | 选择性收集(默认 dry-run) | 准备期 / 事发前 |

### Layer 2 — 角色层工具
| 脚本 | 适用岗位 | 何时跑 |
|------|---------|--------|
| [`scripts/git-evidence-scanner.sh`](scripts/git-evidence-scanner.sh) | 程序员/测试/产品/DevOps | 入职后 1 周内首次,后每周 |
| `bash scripts/git-evidence-scanner.sh --my-email --account-report` | (同上) | **推荐**:只统计自己的 commit + 完整账号分析 |

### Layer 3 — 汇总层工具
| 脚本 | 用途 | 何时跑 |
|------|------|--------|
| [`scripts/unify-summarize.sh`](scripts/unify-summarize.sh) | **统一汇总 → case-brief.md** (推荐) | 律师面谈前 |
| [`scripts/unify-summarize.sh --package`](scripts/unify-summarize.sh) | 统一汇总 + 加密打包 | 律师面谈前 |
| [`scripts/evidence-aggregator.sh`](scripts/evidence-aggregator.sh) | 基础汇总(老接口) | 备选 |

### Incident
| 脚本 | 用途 | 何时跑 |
|------|------|--------|
| [`scripts/incident-tools.sh`](scripts/incident-tools.sh) | 60 秒应急工具 | 事发当日 |

## 🌍 适用法律体系

| 地区 | 法律基础 | 时效 |
|------|---------|------|
| **中国大陆** | 《劳动合同法》《劳动争议调解仲裁法》《民事诉讼法》§63 | 1 年仲裁时效 |
| **中国香港** | 《雇佣条例》 | 6-12 个月 |
| **新加坡** | Employment Act | 6 个月 |
| **美国** | Title VII / FLSA / WARN Act | 各州不同 |

> 本仓库以**中国大陆**法律为主。其他法域的子 skill 见 [issues](https://github.com/your-org/anti-violent-layoff-evidence/issues)。

## 📚 关键术语速查

| 术语 | 含义 |
|------|------|
| **N** | 经济补偿金(每满一年支付一个月工资) |
| **N+1** | 代通知金 + 经济补偿,协商一致解除 |
| **2N** | 违法解除赔偿金(2 倍经济补偿) |
| **加班费** | 工作日 150%、周末 200%、法定节假日 300% |
| **未签合同二倍工资** | 《劳动合同法》§82,入职 1 个月未签起算 |
| **竞业限制** | 离职后不得超过 2 年,公司必须按月支付补偿金 |
| **证据保全** | 公证处、第三方存证平台对证据固定 |
| **司法链** | 蚂蚁、腾讯等法院认可的区块链存证 |
| **TSA 时间戳** | 联合信任时间戳,免费的 RFC 3161 标准时间戳 |

## 🤝 贡献

我们欢迎各种形式的贡献:

- **新的岗位 skill**(医生/律师/教师/公务员 等子 skill)
- **新的法域**(美国/新加坡/英国/德国 维度)
- **新的工具脚本**(自动化导出、证据校验)
- **文档完善**(翻译、配图、案例)
- **法律意见**(声明:贡献者提供的内容仅供参考)

请阅读 [CONTRIBUTING.md](CONTRIBUTING.md) 和 [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)。

## 📋 路线图

### v1.0(2026-07-02)
- ✅ 主 skill (SKILL.md)
- ✅ 程序员/通用岗子 skill
- ✅ 5 个工具脚本
- ✅ 应急 runbook
- ✅ 中英双语 README

### v1.2(2026-07-02)— 当前版本
- ✅ **avle-launcher.sh 引导式主入口**(6 步:邮箱/公司/目录/模块/确认/扫描)
- ✅ **case-brief.md 动态 checklist**(根据实际文件自动勾选 [x])
- ✅ **case-brief.md 证据缺口分析**(根据 git 占比给建议,5% 阈值)
- ✅ launcher 支持 `--quick` / `--resume` / `--config` / `--dry-run`
- ✅ detect_my_emails 加 5s 超时(避免大 ~/ 卡死)

### v1.2 累计(从 v1.1 升)
- ✅ 16 个网盘 + 移动硬盘扫描
- ✅ 法定节假日 + 调休(2024-2026)
- ✅ WFH / 客户现场 / 出差位置记录
- ✅ 程序员 git commit 遍历
- ✅ 三层架构(基础层 + 角色层 + 汇总层)
- ✅ macOS bash 3.2 兼容(关键 bug 修复)
- ✅ git 账号分析(COMPANY vs PERSONAL vs EDU)
- ✅ ~/.config/avle.conf 用户配置
- ✅ 本机实测,case-brief.md 自动生成

### v1.3(计划)
- ⏳ 销售岗子 skill
- ⏳ 财务岗子 skill
- ⏳ 美/港/新法域适配
- ⏳ rust 加速器(cargo install avle-fast-scan)
- ⏳ location-worklog --install-cron
- ⏳ 自动 TSA 时间戳集成

### v2.0(远期)
- ⏳ 跨法域仲裁模板
- ⏳ 区块链存证 SDK 封装
- ⏳ 移动端 App(本地优先)
- ⏳ 工会 / 行业集体行动案例库

## 🙏 致谢

- 中国法律服务网 `https://12348.gov.cn/`
- 12333 劳动维权热线
- 权利卫士 / 至信链(区块链存证)
- 联合信任时间戳(TSA)
- 所有在职场被不公对待过、并选择合法维权的伙伴

## ⚖️ 一句话原则

> **永远不要把所有证据放在别人的服务器上。**
> **永远不要相信"承诺给 N 你签了再说"。**
> **永远不要在情绪激动时做决定。**

---

## 🧪 测试 / Testing

> **说明 / Note**:以下测试数据来自维护者本机实测,**已脱敏**。所有指向性的公司域名 / 个人邮箱 / 机器名均替换为 `@test.com` / `@test-company.com` 形式。
>
> The test data below is from maintainer's local runs and is **anonymized**. All identifying company domains, personal emails, and machine names are replaced with `@test.com` / `@test-company.com`.

- **测试环境 / Environment**:macOS 26.x, bash 5.x / macOS bash 3.2 兼容
- **测试人 / Tester**:`@test-maintainer`
- **典型实测数据 / Typical real-world output**:
  - ~13,000+ 工作文件扫描(8 类扩展名)
  - ~30,000+ git commits 导出(数百个作者)
  - 自动识别**公司 vs 个人** git 账号(`@test.user@<company-domain>` 是公司域,被识别)
  - 55 法定节假日 + 12 调休(2024-2026)同步成功
  - case-brief.md 自动生成 ~140 行

**回归测试 / Regression test**:
```bash
# 1) 检查关联数组兼容(macOS bash 3.2)
for f in scripts/*.sh; do bash -n "$f"; done

# 2) 跑全量(只读,无副作用)
bash scripts/storage-evidence-scanner.sh
bash scripts/git-evidence-scanner.sh --account-report
bash scripts/holiday-sync.sh
bash scripts/unify-summarize.sh
```

**修复的 bug**(v1.1.1):
- 4 个脚本在 macOS bash 3.2 下因 `declare -A` 报错 — 改用变量 / 文件模拟
- git-evidence-scanner 缺账号分析能力 — 新增 `account_group` + `is_mine` 列 + `--account-report`

**用户配置**:`~/.config/avle.conf` 可设 `MY_EMAILS` 和 `COMPANY_DOMAIN`,让 git-evidence 准确识别"你的 commit"

**本机实测数据归档 / Local results archiving**:

> 见 `tests/README.md`。本仓库的 `tests/output/` 目录只保留 `.gitkeep` 框架,
> 不含任何真实数据。维护者本机数据归档在本地(不入仓),用于查漏补缺。
>
> See `tests/README.md`. The `tests/output/` directory in this repo only keeps `.gitkeep` placeholders,
> no real data. Maintainer's local results stay on the local machine (git-ignored) for gap analysis.

---

# 🇺🇸 English

## 🎯 Mission

When an employer suddenly locks your SSO, seizes your computer, takes back your Yubikey, and physically removes you, you should still be able to **prove what you worked on, when, where, how hard, and what you produced** — and claim the compensation you deserve.

## 🧠 Core Methodology

### Evidence Pyramid
```
                    ┌──── TOP ────┐
                    │ Notarization │ Credibility ★★★★★
                    ├── STRONG ────┤
                    │ 3rd-party    │ (Rights-Protector / ZXX-Chain)
                    │ timestamping │
                    ├── PRIMARY ───┤
                    │ Employer SaaS│ (Emails / Tickets)
                    │ exports      │ Authenticity disputable
                    ├── SUPPORT ───┤
                    │ Screenshots  │ ⚠ Need cross-validation
                    │ Self notes   │
                    ├── FALLBACK ──┤
                    │ Self-statement│ Lowest weight
                    └──────────────┘
```
**Key principle**: never store only one copy. Any single piece of evidence may be "flawed", but 3+ independent cross-validating sources reach the **"preponderance of evidence"** standard (PRC Civil Procedure Law §108).

### Three-Phase Timeline
| Phase | Time Window | Mindset | Focus |
|-------|------------|---------|-------|
| **Prevention** | Hire date → Layoff rumors | Proactive | Mass deployment |
| **Evidence Grab** | Notice → Account lock (24-72h) | Tense | Full export + mirror backup |
| **Remedy** | Lockout → 1-year arbitration limit | Rational | Notarize / chain custody / lawyer |

### Three Invariants
| # | Invariant | Attacker's claim | Defender's response |
|---|-----------|-----------------|---------------------|
| I1 | **Fact re-constructible** | "He didn't do it" | Multi-source timestamped evidence |
| I2 | **Identity identifiable** | "That was his private act" | Domain + employee ID + role match |
| I3 | **Chain verifiable** | "Evidence forged later" | hash + timestamp + 3rd-party custody |

## 📦 Repository Structure

Same as Chinese section above.

## 🚀 Quick Start

```bash
# 1) Clone
git clone https://github.com/your-org/anti-violent-layoff-evidence.git
cd anti-violent-layoff-evidence

# 2) Set up evidence dir
mkdir -p ~/evidence/{periodic,incident,timestamp,notarized}

# 3) Configure personal cloud sync
# ✅ OK: Nutstore / Baidu Pan / OneDrive Personal / iCloud / Google Drive
# ❌ NO: Company cloud, Company NAS, anything under company SSO

# 4) Schedule weekly maintenance
echo "0 18 * * 5 bash $(pwd)/scripts/weekly-hash.sh" | crontab -
```

### Pick your role-specific skill

| You are | Read |
|---------|------|
| Developer / QA / PM / DevOps / SRE / Data / Algo / Security | [`skills/developer/SKILL.md`](skills/developer/SKILL.md) |
| HR / Admin / Finance / Sales / Marketing / Ops / Legal / Teacher / Doctor / Civil Servant | [`skills/general/SKILL.md`](skills/general/SKILL.md) |

## 🛠️ Tool Reference

| Script | Purpose | When to run | Default |
|--------|---------|-------------|---------|
| `scripts/weekly-hash.sh` | Weekly hash manifest | Weekly (prevention) | Writes manifest.csv |
| `scripts/evidence-scanner.sh` | Scan local traces | Monthly / preparation | Read-only |
| `scripts/evidence-collector.sh` | Selective collection | Preparation / pre-incident | dry-run, `--apply` encrypts |
| `scripts/evidence-aggregator.sh` | Aggregate into case-brief | Before lawyer meeting | Writes case-brief.md |
| `scripts/incident-tools.sh` | 60-second emergency toolkit | Day of incident | Checklist display |

## 🌍 Jurisdictions

| Region | Legal basis | Limitation |
|--------|-------------|------------|
| **Mainland China** | Labor Contract Law, Labor Dispute Mediation & Arbitration Law, Civil Procedure Law §63 | 1-year arbitration |
| **Hong Kong** | Employment Ordinance | 6-12 months |
| **Singapore** | Employment Act | 6 months |
| **USA** | Title VII / FLSA / WARN Act | Varies by state |

## 📚 Key Terms

| Term | Meaning |
|------|---------|
| **N** | Severance pay (1 month salary per year of service) |
| **N+1** | Pay-in-lieu of notice + severance (mutual termination) |
| **2N** | Compensation for illegal termination (2x severance) |
| **Overtime** | Weekday 150% / Weekend 200% / Holiday 300% |
| **Double wages** | For unsigned contract (PRC Labor Contract Law §82) |
| **Non-compete** | Max 2 years post-termination, requires monthly compensation |
| **Evidence preservation** | Notarization / 3rd-party custody platforms |
| **Judicial chain** | Court-recognized blockchain (Ant Group, Tencent) |
| **TSA timestamp** | Free RFC 3161 timestamp from UTCS |

## 🤝 Contributing

We welcome:

- New role-specific skills (doctor / lawyer / teacher / civil servant, etc.)
- New jurisdictions (US / HK / SG / UK / DE adaptations)
- New tool scripts (automated export, evidence verification)
- Documentation improvements (translations, diagrams, case studies)
- Legal opinions (disclaimer: contributor content is reference only)

Read [CONTRIBUTING.md](CONTRIBUTING.md) and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## 📋 Roadmap

### v1.0 (this release, 2026-07-02)
- ✅ Main skill (SKILL.md)
- ✅ Developer + General role skills
- ✅ 5 tool scripts
- ✅ Emergency runbook
- ✅ Bilingual README

### v1.1 (planned)
- ⏳ Sales role skill
- ⏳ Finance role skill
- ⏳ US / HK / SG jurisdiction adaptation
- ⏳ Full English README expansion
- ⏳ Lawyer / legal aid resource map

### v2.0 (long-term)
- ⏳ Cross-jurisdiction arbitration templates
- ⏳ Blockchain custody SDK wrapper
- ⏳ Mobile app (local-first)
- ⏳ Union / industry collective action case library

## 🙏 Acknowledgments

- China Legal Service Network `https://12348.gov.cn/`
- 12333 Labor Rights Hotline
- Rights-Protector / ZXX-Chain (blockchain custody)
- UTCS (free TSA timestamping)
- All workers who have been treated unfairly and chose the legal path

## ⚖️ One-line Principle

> **Never store all your evidence on someone else's server.**
> **Never sign "trust me, you'll get N" without a lawyer's review.**
> **Never make decisions in emotional heat.**

---

## 📜 License

[MIT License](LICENSE) — free to use, modify, distribute, with copyright notice preserved.

> ⚠️ See LICENSE for full disclaimer. This software is provided for lawful evidence preservation only.

---

<div align="center">

**维护者 / Maintained by**: [@test-maintainer](https://github.com/your-org)  
**版本 / Version**:`v1.0.0`  
**最后更新 / Last updated**:`2026-07-02`  
**报告问题 / Report issues**:[github.com/your-org/anti-violent-layoff-evidence/issues](https://github.com/your-org/anti-violent-layoff-evidence/issues)  
**安全披露 / Security disclosure**:[SECURITY.md](SECURITY.md)

🛡️ **Together we make the workplace more transparent.**

</div>
