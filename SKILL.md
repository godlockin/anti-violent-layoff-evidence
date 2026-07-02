---
name: anti-violent-layoff-evidence
description: 防御性技能合集,在被暴力裁员、锁 SSO/电脑/物理清退时保住工作证明并索取应得赔偿。Defensive skill collection that preserves work evidence when facing sudden account lockout, computer seizure, and violent dismissal, so workers can still claim lawful severance. (主 skill / Main skill)
metadata:
  type: skill
  jurisdiction: 中国大陆 / China Mainland (primary)
  triggers:
    - 反暴力裁员
    - 工作证明
    - 证据保留
    - 锁号
    - 暴力清退
    - 经济补偿
    - 2N 赔偿
    - 仲裁
    - evidence preservation
    - layoff
    - severance
  see_also:
    - skills/developer/SKILL.md
    - skills/general/SKILL.md
    - templates/incident-runbook.md
    - scripts/weekly-hash.sh
  maintainer: @test-maintainer
  version: 1.1.1
  updated: 2026-07-02
---

# 🛡️ 反暴力裁员证据链 / Anti-Violent-Layoff Evidence Chain

> **Defensive toolkit**:在被暴力裁员时,雇主锁 SSO 账号、关电脑、收缴 U 盾、物理清退后,劳动者**仍能**证明工作内容/时间/强度/成果,并据此索取应得赔偿。
>
> **Defensive skill collection**:When employers suddenly lock SSO accounts, seize computers, take back hardware, and physically remove you, you should still be able to prove what you worked on — and claim the compensation you deserve.

## 🇨🇳 中文

**设计哲学 / Design Philosophy**:
- **事前预防** > 事后补救 — Prevention > cure
- **独立存储** > 依赖雇主系统 — Independent storage > employer systems
- **多维冗余** > 单点证据 — Multi-dimensional redundancy > single point
- **可信可采** > 形式堆砌 — Credible & admissible > formal accumulation

**法律边界 / Legal Boundary**:
- 本 skill 仅整理证据保留方法,**不构成法律意见**,不教唆对抗、伪造、报复或侵犯商业秘密。
- This skill provides evidence-preservation methods only,**not legal advice**.
- 具体案件请咨询执业律师。Consult a licensed attorney for your case.

## 🇺🇸 English

**Design Philosophy**:
- **Prevention** > cure
- **Independent storage** > employer systems
- **Multi-dimensional redundancy** > single point
- **Credible & admissible** > formal accumulation

**Legal Boundary**:
- This skill provides evidence-preservation methods only,**not legal advice**.
- Does not encourage retaliation, fabrication, or trade-secret theft.
- Consult a licensed attorney for your case.

---

## 🏛️ 三层架构 / Three-Layer Architecture

> **核心设计 / Core Design**:**所有人先用 general 基础层 → 不同岗位叠加角色层 → 统一汇总层合并出 case-brief**
> **All workers use the general base layer first → add role-specific layer → unified aggregation layer merges into case-brief**

```
┌─────────────────────────────────────────────────────────────┐
│  Layer 3: 统一汇总层 / Unified Aggregation                  │
│          scripts/unify-summarize.sh → case-brief.md        │
│          (把所有 manifest/扫描/记录合并给律师)              │
├─────────────────────────────────────────────────────────────┤
│  Layer 2: 角色层 / Role-Specific (按岗位叠加)              │
│          skills/developer/SKILL.md (程序员/测试/产品/devops)│
│          skills/general/SKILL.md (人事/行政/财务/...)       │
│          ... 未来:sales / finance / legal / medical ...     │
├─────────────────────────────────────────────────────────────┤
│  Layer 1: 基础层 / General Base (全员必跑)                  │
│          skills/general/SKILL.md (适用所有岗位)             │
│          邮件/审批/沟通/纸面/财务/位置/节假日               │
└─────────────────────────────────────────────────────────────┘
```

### 📐 各层职责 / Layer Responsibilities

| 层 | 职责 | 谁跑 | 何时跑 |
|----|------|------|--------|
| **基础层 (general)** | 邮件、审批、沟通、纸面、财务证据、位置记录、节假日 | **全员** | 入职第一天起 |
| **角色层 (developer/...)** | 代码 commit、部署监控、工单、值班等**岗位特有**证据 | 对应岗位 | 入职后 1 周内布点 |
| **汇总层 (unify)** | 把所有 manifest + 扫描结果合并成 case-brief | 律师面谈前 | 事发 → 律师面谈前 |

---

## 🔗 子 skill 导航 / Sub-Skills Navigation

| Layer | 子 skill | 适用岗位 / Applicable Roles |
|-------|---------|--------------------------|
| **基础 + 通用** | [**`skills/general/SKILL.md`**](skills/general/SKILL.md) | **全员必读** / **All roles** — 人事 HR / 行政 / 财务 / 销售 / 市场 / 运营 / 法务 / 教师 / 医护 / 公务员 / 传统行业 |
| **角色** | [**`skills/developer/SKILL.md`**](skills/developer/SKILL.md) | 程序员 / 测试 / 产品 / DevOps / SRE / 数据 / 算法 / 安全 / IT 运维 |

> 💡 **重要**:基础层不重复在 developer skill 里(去重)。developer skill **只**讲代码/部署/工单特有证据。
> The general base layer is NOT duplicated in the developer skill (DRY). developer/SKILL.md ONLY covers code/deployment/tickets.

---

## 🛠️ 工具脚本 / Tool Scripts (按层分类)

### Layer 1 — 基础层脚本(全员必跑)
| 用途 / Purpose | 命令 / Command |
|---------------|---------------|
| 周维护 hash 登记 / Weekly maintenance | `bash scripts/weekly-hash.sh` |
| 扫描本地痕迹 / Scan local traces | `bash scripts/evidence-scanner.sh --json` |
| **全磁盘 + 多网盘扫描**(16 个云盘 + 移动硬盘) / Multi-storage scan | `bash scripts/storage-evidence-scanner.sh` |
| **位置工作记录**(WFH/客户现场/出差) / Location worklog | `bash scripts/location-worklog.sh` |
| **法定节假日同步**(2024-2026 含调休) / Holiday sync | `bash scripts/holiday-sync.sh` |
| 收集证据 / Collect | `bash scripts/evidence-collector.sh --apply` |

### Layer 2 — 角色层脚本
| 用途 / Purpose | 命令 / Command |
|---------------|---------------|
| **程序员 commit 遍历**(所有 git 仓库 + 元数据) | `bash scripts/git-evidence-scanner.sh` |

### Layer 3 — 汇总层脚本
| 用途 / Purpose | 命令 / Command |
|---------------|---------------|
| 基础汇总 / Base aggregate | `bash scripts/evidence-aggregator.sh` |
| **统一汇总(推荐)** / Unified summary → `case-brief.md` | `bash scripts/unify-summarize.sh` |
| **统一汇总 + 加密打包** / With AES-256 package | `bash scripts/unify-summarize.sh --package` |
| **一键跑全部 + 汇总** / Run all + summary | `bash scripts/unify-summarize.sh --run-all` |

### 应急 / Incident
| 用途 / Purpose | 命令 / Command |
|---------------|---------------|
| 60 秒应急工具 / Emergency toolkit | `bash scripts/incident-tools.sh` |

---

## 📋 模板 / Templates

| 用途 / Purpose | 文件 / File |
|---------------|------------|
| 事发当日 runbook / 60s runbook | [`templates/incident-runbook.md`](templates/incident-runbook.md) |
| Hash 登记模板 / Hash manifest | [`evidence-checklist/manifest.csv.template`](evidence-checklist/manifest.csv.template) |

## 🔗 仓库元信息 / Repo Meta

- **仓库地址 / Repository**:`https://github.com/<your-org>/anti-violent-layoff-evidence`
- **作者 / Maintainer**:@test-maintainer
- **当前版本 / Current version**:`v1.0.0`
- **更新日期 / Last updated**:`2026-07-02`
- **许可证 / License**:[MIT](LICENSE) + 法律免责
- **完整说明 / Full docs**:`README.md` / `CONTRIBUTING.md` / `SECURITY.md` / `CHANGELOG.md`

---

---

## 1. 顶层思维 (Strategic Frame)

### 1.1 三大不变量 (Invariants)

| # | 不变量 | 攻击方诉求 | 防御方反制 |
|---|--------|-----------|-----------|
| I1 | **事实可还原** | "他没做过" / "他工作时间不饱和" | 多源时戳证据,证明每一次登录、提交、产出 |
| I2 | **身份可识别** | "这是他私人行为,不代表公司" | 域名+工号+岗位职责匹配,负责人+交接人背书 |
| I3 | **链条可验证** | "证据后期伪造的" | hash + 时间戳 + 第三方存证 + 对方对话呼应 |

### 1.2 证据金字塔 (Evidence Pyramid)

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

**关键原则**:**永远不只存一种**。任何证据单独看都可能"瑕疵",但 3 个以上独立渠道交叉印证 → 法官/仲裁员会认定"高度盖然性"标准(民诉法 §108)。

### 1.3 时间三段论

| 段 | 时间窗 | 心态 | 重点 |
|----|--------|------|------|
| **黄金预防期** | 入职 → 收到裁员风声 | 主动 | 大规模布点(本 skills 的核心) |
| **黄金取证期** | 接到通知 → 锁号(窗口 24-72h) | 紧张 | 全维度导出 + 镜像备份 |
| **救济期** | 锁号后 → 仲裁 1 年时效 | 理性 | 公证 / 区块链固证 / 律师 |

---

## 2. 执行框架 (Execution Framework)

### 2.1 五层布点架构

```
┌─────────────────────────────────────────────────────────┐
│ Layer 5: 法律固证层(公证处/司法链/区块链)  ← 兜底,权威 │
├─────────────────────────────────────────────────────────┤
│ Layer 4: 第三方存证层(云盘/Notion/语雀/GitHub) ← 独立  │
├─────────────────────────────────────────────────────────┤
│ Layer 3: 个人镜像层(本地 + 个人云 双向同步)  ← 即时    │
├─────────────────────────────────────────────────────────┤
│ Layer 2: 雇主系统导出版(邮件转发/工单回流)  ← 推定     │
├─────────────────────────────────────────────────────────┤
│ Layer 1: 现场留痕层(工牌/快递/会见记录/同事互证) ← 物理 │
└─────────────────────────────────────────────────────────┘
```

### 2.2 三动作循环 (Daily / Weekly / Incident)

| 频率 | 动作 | 工具 | 输出 |
|------|------|------|------|
| **每日** | 当天工作产出截图 → 加密压缩 → 推个人云 | rsync / git / 自动化脚本 | `evidence/YYYY-MM-DD/` |
| **每周** | 周度汇总 + hash 登记 + 第三方时间戳 | `scripts/weekly-hash.sh` (本仓提供) | `manifest/YYYY-WW.csv` |
| **事发当日** | 60 秒启动应急包 + 全维度紧急导出 | `templates/incident-runbook.md` | `incident-YYYY-MM-DD.zip` |

---

## 3. 证据清单 (Evidence Manifest)

按"位置 × 渠道 × 方式 × 证据"四元组结构化,每条标注:**可证明什么 + 强制力星级 + 雇主控制力 + 应对策略**。

### 3.1 老板领导管控制制域外证据 (强证据,雇主管不到)

#### A. 物理位置类

| # | 证据来源 | 取证方式 | 证据形式 | 证明内容 | 强制力 | 雇主能删 |
|---|---------|---------|---------|---------|--------|---------|
| A1 | **门禁刷卡记录** | 询问物业或主动查询月度账单 | PDF / 截图 | 在岗时间、地点 | ★★★★ | 较弱 |
| A2 | **公司快递签收单** | 自留底根,扫描上传 | 扫描件 | 在岗日期、岗位职责痕迹 | ★★★ | 较强 |
| A3 | **公司订阅杂志收件人** | 杂志封页自留 | 照片 | 持续工作关系 | ★★★ | 弱 |
| A4 | **访客证/工牌照片** | 入职 / 出差留底 | 高清照片 | 雇佣关系、岗位 | ★★★★ | 弱 |
| A5 | **公司内部摄影/团建照片** | 翻手机相册 | 照片 + EXIF | 工作时长、团队关系 | ★★★ | 弱 |
| A6 | **同事合影/工作场景照**(含你入镜) | 私聊索取 / 朋友圈 | 照片 | 在岗事实 | ★★★★ | 弱 |

#### B. 第三方平台类

| # | 证据来源 | 取证方式 | 证据形式 | 证明内容 | 强制力 | 雇主能删 |
|---|---------|---------|---------|---------|--------|---------|
| B1 | **12333 社保查询** | 当地人社 APP 或官网 | 截图 / PDF | 劳动关系起止月数 | ★★★★★ | 不能 |
| B2 | **个税 APP**(个人所得税) | 自然人电子税务局 | 截图 | 工资数额+申报单位 | ★★★★★ | 不能 |
| B3 | **学信网学位 / 公积金查询** | 央行 / 住建部 | 截图 | 收入状况、关联单位 | ★★★★ | 不能 |
| B4 | **央行征信报告**(含个税贷) | 央行 APP | 截图 | 代发工资行 / 月度入账 | ★★★★ | 不能 |
| B5 | **公积金联名卡入账** | 短信 + 银行 APP | 截图 | 工资数额(可推存续劳动关系) | ★★★★ | 不能 |
| B6 | **企查查 / 天眼查** | 公开查询 | 截图 | 用工主体资质、关联公司 | ★★★ | 不能 |

#### C. 个人生活痕迹类

| # | 证据来源 | 取证方式 | 证据形式 | 证明内容 | 强制力 | 雇主能删 |
|---|---------|---------|---------|---------|--------|---------|
| C1 | **银行工资到账短信** | 转发至私人邮箱 | 短信截图 | 工资金额、日期 | ★★★★ | 不能 |
| C2 | **出差航空行程单** | 航司 APP / 短信 | PDF | 出差日期地点 | ★★★★★ | 不能 |
| C3 | **酒店开票记录**(出差) | 携程/华住 APP | PDF | 出差天数 | ★★★★★ | 不能 |
| C4 | **滴滴行程单**(加班夜归) | 滴滴 APP 导出 | PDF | 加班时段 | ★★★★ | 不能 |
| C5 | **加班外卖/餐费发票** | 美团/饿了么 APP | 截图 | 加班事实 | ★★★ | 不能 |
| C6 | **打车报销记录** | 自己邮箱存根 | 扫描件 | 出差频次 | ★★★ | 不能 |
| C7 | **凌晨朋友圈 / 微博** | 翻找并打包 | 截图 | 加班事实(注意脱敏) | ★★ | 不能 |

#### D. 同事互证类

| # | 证据来源 | 取证方式 | 证据形式 | 证明内容 | 强制力 | 雇主能删 |
|---|---------|---------|---------|---------|--------|---------|
| D1 | **同事邮件互发** | 保留私人抄送 | 邮件归档 | 工作内容、协作关系 | ★★★★ | 较强 |
| D2 | **项目 GitLab commit**(推个人 GitHub) | 个人 mirror | git log | 工作内容、时间 | ★★★★ | 弱 |
| D3 | **行业群 / 同业朋友的私聊** | 截图(防断章) | 截图 + 全文 | 在岗事实、内容细节 | ★★★ | 不能 |
| D4 | **前同事关系链** | 平时保持联系 | 微信/邮件 | 持续证人能力 | ★★★★ | 不能 |

#### E. 离职现场取证(关键!事发当日 60 秒启动)

| # | 证据来源 | 取证方式 | 证据形式 | 证明内容 | 强制力 | 雇主能删 |
|---|---------|---------|---------|---------|--------|---------|
| E1 | **离职面谈录音** | 录音笔 / 手机开录音 | 音频文件 | 解除理由、谈判过程 | ★★★★ | 不能 |
| E2 | **HR 微信对话**(让对方打字) | 微信录屏 | 视频 | 解除理由、补偿方案 | ★★★★ | 不能(但易丢失) |
| E3 | **门卫 / IT 当面交涉** | 手机录像 | 视频 | 收缴过程、暴力程度 | ★★★★ | 不能 |
| E4 | **同事签字的证人声明** | 现状即签 | 书面 | 在岗事实、工作内容 | ★★★★ | 不能 |
| E5 | **快递公司不愿收电脑的声明** | 现场拍摄 | 视频 | 异常清退事实 | ★★★ | 不能 |
| E6 | **执法记录仪/物业监控调取** | 报警后调取 | 视频 | 暴力程度 | ★★★★★ | 不能(可能过期) |

### 3.2 雇主控制域内证据 (强证据,但有被删风险,必须转出)

| # | 证据来源 | 转出方式 | 强制力 | 雇主能删 |
|---|---------|---------|--------|---------|
| F1 | **公司邮件** | 设置自动转发到私人 Gmail/Outlook | ★★★★ | 删原邮箱 ≠ 删你手里 |
| F2 | **Jira/Linear/Asana 工单** | 导出 PDF + 邮件日报抄送个人邮箱 | ★★★★ | 强 |
| F3 | **Slack/钉钉/飞书消息** | 1) Slack 设个人导出 2) 钉钉导出文件 3) 飞书管理员权限 | ★★★★ | 强 |
| F4 | **代码 commit** | 配置 webhook 推到 Gitee/GitLab 个人账号 | ★★★★ | 中(可剥夺 push 权限) |
| F5 | **Notion/Confluence 工作文档** | 邀请个人邮箱为 guest | ★★★★ | 强 |
| F6 | **打卡记录 / 钉钉考勤** | 月度截图+私人邮箱收 OCR 副本 | ★★★★ | 强 |
| F7 | **工资条截图** | 每月截图发个人邮箱 | ★★★★ | 弱(只删你手中) |
| F8 | **钉钉审批/报告** | 流程历史截图,转私人邮箱 | ★★★★ | 强 |
| F9 | **Zoom/腾讯会议录屏** | 个人账号入会(可开云录) | ★★★ | 强 |
| F10 | **API 监控/Prometheus / Grafana 看板** | 个人脚本抓快照 | ★★★ | 强 |

### 3.3 雇主控制域内"暗证明"(看似无害,实则有力的证据)

| # | 证据来源 | 取证方式 | 强制力 |
|---|---------|---------|--------|
| G1 | **公司 WiFi 接入日志** | 个人设备连一次后看路由器后台 | ★★★ |
| G2 | **MAC 地址绑定打印记录** | 用个人设备打印,在打印机排队记录留痕 | ★★★ |
| G3 | **门禁系统管理员端查询** | 用 IT 同事/前同事友情截图 | ★★★★ |
| G4 | **Saas 工号**(SSO 用户名) | 截图 SSO 个人页 | ★★★★ |
| G5 | **公司 Git 仓库 contributor 统计** | GitHub 个人账号有镜像 | ★★★★ |
| G6 | **企查查/天眼查任职信息** | 个人公开查询 | ★★★★★ |

### 3.4 ⚠️ 禁止区域(有刑事风险)

- ❌ 删公司文件 / 删老板电脑
- ❌ 用未授权账号外发商业机密
- ❌ 破坏公司服务器、删库跑路
- ❌ 删 SAP/Oracle 数据库
- ❌ 用预留账号远程锁公司系统
- ❌ 删除监控录像
- ❌ 收钱后违约不交接

> 这些行为会从"受害者"变"加害者",得不偿失。

---

## 4. 主动布点 (Proactive Setup,推荐在还没出事时执行)

### 4.1 入职第一天 - 立刻布的 5 个点

```bash
# 1. 个人邮箱自动同步
Gmail 设置过滤器: from:@your-company.com → 自动加标签 + 不删

# 2. 公司邮箱转发 (谨慎使用,部分公司禁止)
公司邮箱 → 设置转发 → 个人 Gmail (过滤敏感词)

# 3. Git 镜像
git remote add personal git@github.com/yourname/priv-mirror.git
git push personal --mirror (每周一次)

# 4. 个人日历订阅
Outlook/CalDAV → 用 read-only link 同步到个人日历

# 5. Slack export
Slack → "Settings → Data export" 申请,每周自动邮件发送
```

### 4.2 每周五 - 30 秒周维护

```bash
# scripts/weekly-hash.sh 一键执行
bash scripts/weekly-hash.sh

# 自动完成:
# 1. git mirror push
# 2. manifest csv hash 登记
# 3. 本地 → 个人云(坚果云)rsync
# 4. 邮件归档月份打包
```

### 4.3 每月 - 月度 deep 保留

```bash
# 1. 工资截图 → 个人邮箱
# 2. 个税 APP 截图 → 个人云
# 3. 社保 APP 截图 → 个人云
# 4. 公积金入账截图 → 个人云
# 5. 银行工资流水导出 PDF → 个人云
```

---

## 5. 事发当日 - 60 秒应急包 (Incident Runbook)

### 5.1 接到解除通知的 **第一分钟**

| # | 动作 | 备注 |
|---|------|------|
| 1 | **深呼一口气,不签字** | 当下任何签字都是对你不利 |
| 2 | **开录音** | 手机录音笔同时开,**广东高院 2017 判例**支持单方秘密录音 |
| 3 | **微信问 HR"请用文字确认解除原因、补偿方案、生效时间"** | 把话逼到文字 |
| 4 | **调取已知密码的最后备份** | 个人云、个人邮箱、个人微信 |
| 5 | **给家人发定位 + "今天可能被暴力清退"** | 物理安全 |

### 5.2 24 小时内的 **6 个必拿证据**

| # | 证据 | 操作 |
|---|------|------|
| 1 | 全维度邮件导出 | Mailbird / Thunderbird 离线拉 + 个人云 |
| 2 | SaaS 平台个人导出 | Slack/Jira/Notion 申请 Data Export |
| 3 | 钉钉/飞书消息备份 | 进入设置 → 数据导出(部分平台仅本人可见) |
| 4 | 微信工作群完整记录 | 迁移聊天记录到另一台设备 |
| 5 | Git 全镜像 clone(不带公司账号) | SSH key 已配置即可 |
| 6 | 本地工作文件夹全打包加密 | 7-zip 加密 → 个人云 |

### 5.3 72 小时内 - **法律固证**

| # | 行动 | 说明 |
|---|------|------|
| 1 | **公证处** | 直接带证据去线下公证处办理(一天出证,2000-5000 元) |
| 2 | **司法链 / 至信链** | "权利卫士"小程序上传截图,30 元/份 |
| 3 | **时间戳固化** | 联合信任时间戳(TSA)免费 |
| 4 | **律师介入** | 1 元/年法律援助,大所劳动组合 200-500 元首次咨询 |
| 5 | **劳动监察大队举报** | 12333 + 现场,但不要把鸡蛋放一个篮子 |

---

## 6. Failover 应对策略 (红蓝对抗)

### 6.1 雇主典型反制 与 我们的预案

| # | 雇主动作 | 我们预案 |
|---|---------|---------|
| R1 | "我们通知你今天解除劳动合同" | 录音 + **拒绝当场签字**, 要求带回去看 |
| R2 | "你违反了保密协议"(莫须有) | 提供工作日志,反问:具体哪一天?什么文件? |
| R3 | "给你 N,你签" | 不签 → 协商一致是 N+1,违法解除是 2N,先验算 |
| R4 | "你的电脑要回收" | 全备份后再交,要求 IT 出具**设备清单交接单** |
| R5 | "你的账号已经冻结" | **替代方案**:之前已自动同步到个人云,无影响 |
| R6 | "你的考勤全旷工" | 钉钉打卡截图 + 个税 + 公积金 + 自存日志反击 |
| R7 | "Slack/Slackbot 是你自己注册的" | 个人账号开的、公司域名、企业 SSO 接入证明 |
| R8 | "你这证据是 P 图" | 哈希值 + 公证 + 区块链 hash,法官认可 |
| R9 | "你这是敲诈,要告你" | 要求对方举证,任何调解都有录音 |
| R10 | "我们不发离职证明" | 仲裁前可主张,赔 2000-20000 损失(最高法案例) |
| R11 | "你的期权/股票作废" | 启动竞业限制/股权保留法律分析 |
| R12 | "同业竞业违反,要你赔 100 万" | 反诉:竞业限制必须每月给补偿金才生效 |

### 6.2 个人反取证识别与逃生

如果你发现:
- 电脑突然变慢(可能装键盘记录器)
- 公司网络 IP 异常(可能终端监控)
- 敏感词邮件被退信(可能邮件审计)
- 同事突然疏远(可能公司施压)
- 你的私家账号突然被"骚扰"(密码可能已泄)

**逃生动作**:
1. 用**私人设备**做关键取证,避免公司设备
2. 用**私人网络**(手机 4G/5G),避免公司网络审计
3. 关键截图用**手机自带水印**(华为/小米带元数据)
4. 给**可信律师**发私钥加密邮件(GPG/SMIME)

### 6.3 最坏情况 - 完全失联预案

如果某天**早上醒来发现自己登不上任何东西**:

| # | 动作 |
|---|------|
| 1 | 物理安全:不要去公司,先去朋友家 |
| 2 | 启动本地应急包:**scripts/incident-tools.sh** |
| 3 | 联系律师:已知 3 家律所 24h 应急电话 |
| 4 | 联系家属:财务支援、检查社保医保、公积金提现 |
| 5 | 个人邮箱 / 云盘 / 微信 = 仍是你的,他们进不来 |
| 6 | 个税 APP 自查:用人单位是否还在给你申报(可能被代缴) |
| 7 | 12333 投诉被非法解除 + 12345 政府热线 |
| 8 | 仲裁立案窗口:1 年,先进人社局仲裁窗口登记 |

---

## 7. 输出清单 (Deliverables)

执行本 skills 后,你应当拥有的本地资料:

```
~/evidence/
├── README.md                          # 索引
├── 2024-Q1/                           # 每季度
│   ├── 邮件归档-2024-Q1.tar.gz.enc
│   ├── 工单归档-2024-Q1.tar.gz.enc
│   ├── 钉钉消息-2024-Q1.tar.gz.enc
│   └── 月度工资条-2024-01.jpg ... 12.jpg
├── manifest.csv                       # hash 登记
├── 时间戳证书/                         # 联合信任
├── 公证书/                             # 重要节点
└── incident/
    └── 2026-XX-XX-暴力裁员/
        ├── 录音-面谈.mp3
        ├── 微信截图/
        ├── 设备交接单.png
        └── 律师委托书.pdf
```

---

## 8. 法律边界与免责 (Ethics & Boundary)

### 8.1 ⚠️ 不要做

- ❌ 偷窃商业秘密、客户名单
- ❌ 报复性删库、勒索、骚扰
- ❌ 删除公司合法资产
- ❌ 伪造证据
- ❌ 以曝光要挟敲诈勒索

### 8.2 ✅ 应该做

- ✅ 完整保留属于你的工作产物副本
- ✅ 用公开合法渠道监督雇主
- ✅ 走劳动监察、仲裁、诉讼
- ✅ 主张自身合法权益(N、N+1、2N)

### 8.3 法律依据

- 《劳动合同法》§ 36/39/40/41/46/47/48/87
- 《劳动争议调解仲裁法》§ 27 (1 年时效)
- 《民事诉讼法》§ 63 (证据种类) / § 108 (高度盖然性)
- 《最高人民法院关于民事诉讼证据的若干规定》(法释〔2019〕19 号)
- 《个人所得税法》(雇主代扣代缴义务)
- 《社会保险法》(雇主缴费义务)
- 《工会法》

---

## 9. 关键术语速查

| 术语 | 含义 |
|------|------|
| N | 经济补偿金(每满一年支付一个月工资) |
| N+1 | 代通知金 + 经济补偿,协商一致解除 |
| 2N | 违法解除赔偿金(2 倍经济补偿) |
| 加班费 | 工作日 150%、周末 200%、法定节假日 300% |
| 未签合同二倍工资 | 《劳动合同法》§82,入职 1 个月未签起算 |
| 竞业限制 | 离职后不得超过 2 年,公司必须按月支付补偿金 |
| 证据保全 | 公证处、第三方存证平台对证据固定 |
| 司法链 | 蚂蚁、腾讯等法院认可的区块链存证 |

---

## 10. 关联资源

- **本仓 templates/**: `incident-runbook.md`(事发当日手册)、`weekly-manifest.csv`(周维护表)
- **本仓 scripts/**: `weekly-hash.sh`(周自动 hash)、`incident-tools.sh`(应急工具)
- **本仓 evidence-checklist/**: 7 张证据维度分清单 PDF
- **外部权威**:
  - 中国法律服务网 `https://12348.gov.cn/`
  - 全国人社政务服务平台
  - 国家税务总局个税 APP
  - 12333 劳动维权热线
  - 当地公证处(线下)
  - 权利卫士 / 至信链(区块链存证)
  - 联合信任时间戳(TSA)

---

## 11. 一句话原则

> **永远不要把所有证据放在别人的服务器上。**
> **永远不要相信"承诺给 N 你签了再说"。**
> **永远不要在情绪激动时做决定。**

---

**版本**:v1.0(2026-07-02)
**设计**:@test-maintainer,工作日内持续迭代
