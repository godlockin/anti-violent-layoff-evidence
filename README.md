# Anti-Violent-Layoff Evidence (AVLE) / 反暴力裁员证据链

> **防御性技能合集**:在雇主单方面锁号、关电脑、收缴 U 盾、物理清退时,劳动者**仍能**证明工作内容、时间、地点、强度、成果,并据此索取应得赔偿。
>
> **Skill Collection**:Defensive toolkit for workers facing sudden account lockouts, computer seizure, and violent dismissal. Provides evidence-gathering frameworks, automated tools, and best practices across multiple job roles.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Evidence Tools](https://img.shields.io/badge/evidence-tools-blue.svg)](scripts/)
[![Skills: 2](https://img.shields.io/badge/skills-developer%20%2B%20general-green.svg)](skills/)

---

## ⚠️ 法律声明 / Legal Notice

> **本仓库仅整理证据保留方法,不构成法律意见,不教唆对抗、伪造、报复或侵犯商业秘密。具体案件请咨询执业律师。**
>
> **This repo provides evidence-preservation methods only, not legal advice. Do not use for retaliation, evidence fabrication, or trade-secret theft. Consult a licensed attorney for your case.**

合法用途 (Lawful uses):
- ✅ 完整保留属于你的工作产物副本
- ✅ 主张自身合法权益(N、N+1、2N、加班费)
- ✅ 走劳动监察、仲裁、诉讼
- ✅ 用公开合法渠道监督雇主

禁止行为 (Prohibited):
- ❌ 偷窃商业秘密、客户名单
- ❌ 报复性删库、勒索、骚扰
- ❌ 删除公司合法资产
- ❌ 伪造证据
- ❌ 以曝光要挟敲诈勒索

---

## 🎯 核心目标 / Mission

在以下三种攻击面下保住证据:

| # | 攻击面 | 雇主动作 | 我们反制 |
|---|--------|---------|---------|
| **I1** | **数字锁死** | 锁 SSO、删 SaaS、清云盘 | 镜像推个人云 + GitHub |
| **I2** | **物理剥夺** | 收电脑、U 盾、工牌 | 物理证据位 + 同事互证 |
| **I3** | **否认** | "他没做过" / "工作时间不饱和" | 多源时戳证据 + 第三方存证 |

---

## 📦 仓库结构 / Repository Structure

```
anti-violent-layoff-evidence/
├── README.md                          ← 你在这里
├── LICENSE                            ← MIT
├── CONTRIBUTING.md                    ← 贡献指南
├── CHANGELOG.md                       ← 变更日志
├── SECURITY.md                        ← 安全策略
├── CODE_OF_CONDUCT.md                 ← 行为准则
│
├── SKILL.md                           ← 主 skill (顶层思维 + 证据清单)
│
├── scripts/                           ← 可执行工具
│   ├── weekly-hash.sh                 ← 周维护 (30 秒)
│   ├── evidence-scanner.sh            ← 扫描本地痕迹
│   ├── evidence-collector.sh          ← 选择性收集
│   ├── evidence-aggregator.sh         ← 生成 case-brief.md
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
    ├── developer/SKILL.md             ← 程序员/测试/产品/devops
    └── general/SKILL.md               ← 人事/行政/财务/销售 等
```

---

## 🚀 快速开始 / Quick Start

### 1. 预防期(现在就开始,不需要任何背景)

```bash
# 1) 克隆本仓库(或直接下载)
git clone https://github.com/<your-org>/anti-violent-layoff-evidence.git
cd anti-violent-layoff-evidence

# 2) 建立你的证据目录
mkdir -p ~/evidence/{2026-Q1,incident,timestamp,notarized}

# 3) 配置个人云同步
# 推荐:坚果云 / 百度网盘 / OneDrive 个人版 / iCloud / Google Drive
# 不要用:公司提供的云盘、公司配的 NAS、公司域账号下的任何 SaaS

# 4) 设置周维护 cron (每周五 18:00)
echo "0 18 * * 5 bash $(pwd)/scripts/weekly-hash.sh" | crontab -
```

### 2. 按岗位选用子 skill

| 你是谁 | 看哪个 skill |
|--------|------------|
| 程序员/测试/产品/DevOps/算法/数据/安全 | [`skills/developer/SKILL.md`](skills/developer/SKILL.md) |
| 人事/行政/财务/销售/市场/运营/法务/教师/医护/公务员 | [`skills/general/SKILL.md`](skills/general/SKILL.md) |

### 3. 事发当日(60 秒启动)

```bash
# 查看应急 runbook
cat templates/incident-runbook.md

# 启动 60 秒应急工具
bash scripts/incident-tools.sh
```

### 4. 事后汇总(交给律师前)

```bash
# 1) 扫描本地可作为证据的痕迹
bash scripts/evidence-scanner.sh --json

# 2) 选择性收集(默认 dry-run,确认后 --apply)
bash scripts/evidence-collector.sh --plan
bash scripts/evidence-collector.sh --apply

# 3) 汇总成 case-brief.md 交给律师
bash scripts/evidence-aggregator.sh
```

---

## 🛠️ 工具速查 / Tool Reference

| 脚本 | 用途 | 何时跑 |
|------|------|--------|
| `scripts/weekly-hash.sh` | 每周五自动 hash 登记 | 每周(预防) |
| `scripts/evidence-scanner.sh` | 扫描本地可作为证据的痕迹 | 每月 / 准备期 |
| `scripts/evidence-collector.sh` | 按计划选择性收集(只读) | 准备期 / 事发前 |
| `scripts/evidence-aggregator.sh` | 汇总所有 manifest 出 case-brief | 律师面谈前 |
| `scripts/incident-tools.sh` | 60 秒应急工具合集 | 事发当日 |

---

## 📚 核心概念 / Core Concepts

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
                    ├──── 兜底 ────┐
                    │ 当事人陈述   │ 自述证据,效力最低
                    └─────────────┘
```

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
| I2 | **身份可识别** | "这是他私人行为" | 域名+工号匹配 |
| I3 | **链条可验证** | "证据后期伪造" | hash + 时间戳 + 公证 |

---

## 🌍 适用法律体系 / Jurisdictions

| 地区 | 法律基础 | 时效 |
|------|---------|------|
| **中国大陆** | 《劳动合同法》《劳动争议调解仲裁法》《民事诉讼法》§63 | 1 年仲裁时效 |
| **中国香港** | 《雇佣条例》 | 6-12 个月 |
| **新加坡** | Employment Act | 6 个月 |
| **美国** | Title VII / FLSA / WARN Act | 各州不同 |

> 本仓库以**中国大陆**法律为主。其他法域的子 skill 见 [issues](https://github.com/.../issues)。

---

## 🤝 贡献 / Contributing

我们欢迎各种形式的贡献:

- **新的岗位 skill**(医生/律师/教师/公务员 等子 skill)
- **新的法域**(美国/新加坡/英国/德国 维度)
- **新的工具脚本**(自动化导出、证据校验)
- **文档完善**(翻译、配图、案例)
- **法律意见**(声明:贡献者提供的内容仅供参考)

请阅读 [CONTRIBUTING.md](CONTRIBUTING.md) 和 [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)。

---

## 📋 路线图 / Roadmap

### v1.0(本版本 2026-07-02)
- ✅ 主 skill (SKILL.md)
- ✅ 程序员/通用岗子 skill
- ✅ 5 个工具脚本
- ✅ 应急 runbook

### v1.1(计划)
- ⏳ 销售岗子 skill
- ⏳ 财务岗子 skill
- ⏳ 美/港/新法域适配
- ⏳ 英文 README
- ⏳ 律师 / 法律援助资源地图

### v2.0(远期)
- ⏳ 跨法域仲裁模板
- ⏳ 区块链存证 SDK 封装
- ⏳ 移动端 App(本地优先)
- ⏳ 工会 / 行业集体行动案例库

---

## 🙏 致谢 / Acknowledgments

- 中国法律服务网 `https://12348.gov.cn/`
- 12333 劳动维权热线
- 权利卫士 / 至信链(区块链存证)
- 联合信任时间戳(TSA)
- 所有在职场被不公对待过、并选择合法维权的伙伴

---

## 📜 许可证 / License

[MIT License](LICENSE) - 自由使用、修改、分发,只要保留版权声明。

---

## ⚖️ 一句话原则 / One-line Principle

> **永远不要把所有证据放在别人的服务器上。**
>
> **Never store all your evidence on someone else's server.**

---

**仓库维护 / Maintained by**:@test-maintainer  
**当前版本 / Current version**:v1.0  
**最后更新 / Last updated**:2026-07-02
