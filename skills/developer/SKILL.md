---
name: developer-evidence
description: 程序员/测试/产品/DevOps/SRE/数据/算法/安全 岗位专属证据维度 - 代码 commit/部署监控/工单/值班。Role-specific evidence dimensions for Developer, QA, PM, DevOps, SRE, Data, Algo, Security — code commits, deployment logs, tickets, on-call records.
metadata:
  type: sub-skill
  parent: anti-violent-layoff-evidence
  roles:
    - developer
    - qa
    - product-manager
    - devops
    - sre
    - data-engineer
    - data-scientist
    - algo-engineer
    - security-engineer
    - it-admin
  jurisdiction: 中国大陆 / China Mainland (primary)
  triggers:
    - 程序员证据
    - code commit 证据
    - 部署日志
    - 值班记录
    - developer evidence
    - deployment log
    - on-call record
  see_also:
    - ../../SKILL.md
    - ../general/SKILL.md
    - ../../templates/incident-runbook.md
    - ../../scripts/weekly-hash.sh
  maintainer: "@test-maintainer"
  version: 1.1.1
  updated: 2026-07-02
---

# 💻 程序员岗位 evidence skill / Developer & Tech Roles Evidence

> **适用岗位 / Applicable Roles**:**研发 / 测试 / 产品 / DevOps / SRE / 数据 / 算法 / 安全 / IT 运维**
> **Developer / QA / PM / DevOps / SRE / Data / Algo / Security / IT Operations**
>
> **共同特征 / Common Trait**:工作产物**100% 可数字化** → 证据最丰富、最强证据、最容易自证,反而是维权最有利的群体。
> **Work products 100% digitalizable** → richest evidence, strongest proof, easiest self-defense.
>
> **关键差异 / Key Difference**:程序员的核心证据在**代码、commit、部署、监控、值班**; 而非打卡、邮件。
> **Core evidence**: code, commits, deployments, monitoring, on-call — not check-in or email.
>
> **本 skill 重点 / Focus**:**保住源代码和部署痕迹** = 保住工作量和价值。
> **Preserve source code & deployment traces = preserve your contribution and value.**

## 🔗 联动 / Links

- **主 skill** / Main skill:[`../../SKILL.md`](../../SKILL.md)
- **同侪子 skill** / Peer sub-skill:[`../general/SKILL.md`](../general/SKILL.md)
- **应急 runbook** / Incident runbook:[`../../templates/incident-runbook.md`](../../templates/incident-runbook.md)
- **周维护** / Weekly maintenance:[`../../scripts/weekly-hash.sh`](../../scripts/weekly-hash.sh)
- **仓库** / Repository:`https://github.com/your-org/anti-violent-layoff-evidence`

---

---

## 0. 程序员的"职业病式"反讽(必须先治)

> 程序员最擅长"系统化做事",反而被"系统化锁号"打倒,因为从未想过锁号场景。

| 心理 | 陷阱 | 治根 |
|------|------|------|
| "我贡献了关键模块,公司离不开" | 锁号后才发现"代码在我脑子里" | 镜像推个人 Git |
| "我天天写 commit,Git 是天然的证据" | 离职后仓库被设为 private,SSH key 失效 | 立刻镜像 |
| "我有 24h oncall,加班数据看监控" | 监控在 Grafana 云上,账号进不去 | 提前自动截图 |
| "公司发我 MacBook,是我的" | 合同写"公司财产",Yours is yours | 物理保全是公司,数据保全是你的 |

---

## 1. 程序员的"五大证据山脉"

### 山脉 1:代码 / 文档 (最重要)

| # | 证据 | 取证方式 | 强度 | 雇主能删 |
|---|------|---------|------|---------|
| DEV-1 | **个人 Git 镜像** | `git push personal` 每周一 | ★★★★★ | 中(可封 push) |
| DEV-2 | **Gitee / GitCode 镜像** | 配置 webhook 自动同步 | ★★★★★ | 弱(公网) |
| DEV-3 | **代码片段 (gist)** | 重要模块每日归档到 Gist | ★★★ | 不能 |
| DEV-4 | **自写 README/ADR** | 重要决策每日写 markdown 推 Notion/语雀 | ★★★★ | 强 |
| DEV-5 | **PR 邮件通知** | 配 GitHub/GitLab 邮件推送私人邮箱 | ★★★★ | 弱 |
| DEV-6 | **Code Review 评论** | 截图保存 | ★★★★ | 强 |
| DEV-7 | **自审 MR 历史** | 导出 JSON | ★★★ | 强 |
| DEV-8 | **commit 签名 (GPG)** | 私钥在个人 GPG keychain | ★★★★★ | 不能 |
| DEV-9 | **Contributor 统计图** | 个人 GitHub 主页截图 | ★★★★ | 弱(公网) |
| DEV-10 | **CI 构建产物** | Jenkins/GitHub Actions 制品,推个人 S3 | ★★★ | 强 |

**反侦察**:
- 不要把公司代码写进个人 GitHub (可能涉商业秘密,刑事风险)
- 用**脱敏后**的代码片段 + commit **message** 即可
- 重点保留 **commit message 原文**、**PR 标题**、**讨论 thread**

### 山脉 2:部署 / 运维 / 监控

| # | 证据 | 取证方式 | 强度 | 雇主能删 |
|---|------|---------|------|---------|
| OPS-1 | **生产部署日志** | kubectl logs / docker logs 截取推 Sentry | ★★★★ | 强 |
| OPS-2 | **个人 curl / ssh 截图** | 部署完成后用手机拍照 | ★★★ | 不能 |
| OPS-3 | **Prometheus 看板快照** | 每周一 09:00 推个人邮箱 | ★★★★ | 强 |
| OPS-4 | **Grafana 导出 PDF** | 关键时段每天导出 | ★★★★ | 强 |
| OPS-5 | **告警响应记录** | 钉钉/飞书/邮件告警截图 | ★★★★ | 强 |
| OPS-6 | **值班排班表** | 钉钉值班表截图推个人 | ★★★★ | 强 |
| OPS-7 | **事故复盘 (Postmortem)** | 自存副本 | ★★★★★ | 强 |
| OPS-8 | **服务器 IP / 域名清单** | 自维护 spreadsheet | ★★★ | 强 |
| OPS-9 | **CI/CD pipeline 配置** | 截图保留 | ★★★ | 强 |
| OPS-10 | **生产事故应急群** | 消息转私人微信 | ★★★★ | 强 |

### 山脉 3:工单 / 任务 / 项目管理

| # | 证据 | 取证方式 | 强度 | 雇主能删 |
|---|------|---------|------|---------|
| TASK-1 | **Jira 工单** | 配 Outlook 同步,自动抄送个人邮箱 | ★★★★★ | 强 |
| TASK-2 | **Linear / Asana / Trello** | 配邮件 digest 推私人 | ★★★★ | 强 |
| TASK-3 | **Notion 工作区** | 配个人邮箱为 guest | ★★★★ | 强 |
| TASK-4 | **Confluence 知识库** | 导出 PDF 推送个人 | ★★★★ | 强 |
| TASK-5 | **飞书文档权限截图** | 显示你为 Owner/Editor | ★★★★ | 强 |
| TASK-6 | **OKR 文档** | 月度复盘截图 | ★★★★ | 强 |
| TASK-7 | **Sprint 燃尽图** | 截图 | ★★★ | 强 |
| TASK-8 | **每日站会纪要** | 截图 | ★★★ | 强 |
| TASK-9 | **产品 PRD 自写部分** | 截图 | ★★★★ | 强 |
| TASK-10 | **Bug 提交 / 解决清单** | 个人副本 | ★★★ | 强 |

### 山脉 4:协作 / 沟通 / 即时消息

| # | 证据 | 取证方式 | 强度 | 雇主能删 |
|---|------|---------|------|---------|
| CHAT-1 | **Slack 全量导出** | 申请 Personal Export | ★★★★ | 强 |
| CHAT-2 | **钉钉群聊天** | 自带"备份"功能 | ★★★★ | 强 |
| CHAT-3 | **飞书消息** | 导出功能 | ★★★★ | 强 |
| CHAT-4 | **Teams 聊天** | 配个人 Microsoft 账号 | ★★★★ | 强 |
| CHAT-5 | **Zoom/腾讯会议** | 配个人账号,开云录 | ★★★ | 强 |
| CHAT-6 | **邮件全量** | Thunderbird 离线拉 | ★★★★★ | 强 |
| CHAT-7 | **技术博客 / 公众号** | 自己写的署名,证明专业身份 | ★★★ | 不能 |
| CHAT-8 | **技术社区回答 (思否/掘金)** | 截图 | ★★★ | 不能 |
| CHAT-9 | **Stack Overflow 账号** | 截图 | ★★ | 不能 |
| CHAT-10 | **技术分享会 Slides** | 个人账号 reupload | ★★★ | 强 |

### 山脉 5:外部可证 / 个人痕迹

| # | 证据 | 取证方式 | 强度 | 雇主能删 |
|---|------|---------|------|---------|
| OUT-1 | **GitHub 主页 contribution** | 截图(可看出当日是否有提交,即便被锁号后) | ★★★★ | 弱(公网) |
| OUT-2 | **GitHub 邮箱公开 commit** | 截图 | ★★★★★ | 弱(公网) |
| OUT-3 | **个人博客发文** | 截图 | ★★★ | 不能 |
| OUT-4 | **技术大会出席** | 公开讲者名单(可搜名字) | ★★★ | 不能 |
| OUT-5 | **专利署名** | 国知局公开查询 | ★★★★★ | 不能 |
| OUT-6 | **论文署名** | 知网公开查询 | ★★★★★ | 不能 |
| OUT-7 | **企查查 / 天眼查** | 任职信息 | ★★★★★ | 不能 |
| OUT-8 | **个税 APP** | 月度申报记录 | ★★★★★ | 不能 |
| OUT-9 | **公积金 / 社保** | APP 查询 | ★★★★★ | 不能 |
| OUT-10 | **脉脉 / LinkedIn 公开档案** | 截图 | ★★★ | 不能 |

---

## 2. 程序员专属"暗证据"(高价值、低被取证)

| 暗证据 | 取证方式 | 价值 |
|--------|---------|------|
| **公司域名 + 工号 → 个人主页** | 你的 GitHub bio 写了 `@xxx @ CompanyName` | 雇主可质证 |
| **commit message 里的工作背景** | 关键 commit 截图(脱敏后) | 证明项目范围 |
| **API 监控 + 个人 Grafana 账号** | 镜像一份业务数据图 | 证明系统重要性 |
| **飞书日历订阅地址** | 同步到个人日历 | 证明会议/任务量 |
| **VPN 连接日志(手机端)** | 截图 | 证明加班 |
| **公司 WiFi mac 绑定记录** | 用私人手机连一次,留截图 | 证明到岗 |
| **个人电脑访问公司系统的 mac 地址** | 公司网络后台可查 | 强证据 |

---

## 3. 程序员专属 Failover (雇主反制预案)

| # | 雇主动作 | 程序员预案 |
|---|---------|-----------|
| D-1 | "你的代码 100% 属于公司,你没拿" | 我们的目标不是拿代码,只是**证明你写过** |
| D-2 | "你的 GitHub 上的代码是泄密" | 提前只 mirror **commit message + 时间**,不上传代码 |
| D-3 | "你私下用公司电脑挖矿/做私活" | 私人电脑不在公司网络,公司无证据 |
| D-4 | "你的 commit 数量不饱和" | GitHub 个人主页 + GitLab 内部统计截图 |
| D-5 | "你主要做维护,没新项目" | 个人 Gist/Notion 写复盘 + 量化产出 |
| D-6 | "你的告警响应超时" | PagerDuty 截图,显示你 1 分钟响应 |
| D-7 | "你的代码质量差,影响生产" | Code Review 截图,显示多人批准 |
| D-8 | "你拒绝交接" | 准备好**带视频的交接会议** + 邮件确认清单 |
| D-9 | "你的 OKR 未完成" | 自存工作日志,量化周进度,反驳 |
| D-10 | "你同业竞业" | 提前检查竞业条款,出 grep 报告 |

---

## 4. 程序员自存工作日志 (必备!)

```bash
# scripts/developer-daily-log.sh
DATE=$(date +%Y-%m-%d)
LOG="$HOME/evidence/developer-log/$DATE.md"
mkdir -p "$(dirname "$LOG")"

cat > "$LOG" <<EOF
# $DATE 工作日志

## 完成 (Done)
- [ ] ___

## 进行中 (In Progress)
- ___

## 关键决策 (Decision)
- 决策:___
- 原因:___
- 参与人:___

## 会议 (Meeting)
- 时间:___
- 主题:___
- 结论:___

## 产出链接 (Links)
- PR/工单:___
- 设计文档:___
- 部署记录:___

## 工作时间
- 09:00 - 18:30 (8.5h)
- 加班: 19:00 - 22:00 (3h)

## 今日思考
___
EOF
```

---

## 5. 测试 / QA 岗位特别提示

| 维度 | 重点证据 |
|------|---------|
| **用例设计** | 测试用例库导出 PDF |
| **缺陷跟踪** | Jira/Zentao Bug 列表 |
| **自动化脚本** | 推个人 Git |
| **覆盖率报告** | Allure 报告截图 |
| **兼容性测试** | BrowserStack 截图 |
| **性能测试** | JMeter 报告导出 |
| **验收文档** | 签字版截图 |
| **事故复盘** | 协助研发事故复盘截图 |

**暗坑**:很多测试用了"假名"或"花名"在系统,需提前把工号、真实姓名关联好。

---

## 6. 产品岗位特别提示

| 维度 | 重点证据 |
|------|---------|
| **PRD 文档** | 飞书/Notion 个人副本 |
| **用户调研** | 录音 + 报告 |
| **数据分析** | 神策/GrowingIO 截图 |
| **产品决策** | 邮件 thread 截图 |
| **上线项目** | App Store / 内部公告截图 |
| **用户反馈** | 自维护 spreadsheet |
| **OKR / KPI** | 季度复盘截图 |
| **竞品分析** | 推个人飞书 |

**暗坑**:产品价值难量化,需提前**量化**:DAU 提升 x%、NPS +y 分、转化率 +z%。

---

## 7. DevOps / SRE 岗位特别提示

| 维度 | 重点证据 |
|------|---------|
| **生产部署** | kubectl / docker logs 个人副本 |
| **监控告警** | 截图推个人 Slack |
| **事故响应** | 飞书/钉钉事故群全量导出 |
| **值班记录** | 值班表 + 告警截图 |
| **架构演进** | 个人 GitOps 仓库 |
| **成本优化** | 云厂商账单截图(脱敏) |
| **容量规划** | 飞书文档个人副本 |
| **安全审计** | 漏洞修复记录 |

**暗坑**:DevOps 是"兜底者"也是"背锅侠",事故复盘时必须有书面"风险提示邮件"。

---

## 8. 关键紧急动作 (24h CheckList)

```
□ 推个人 Git mirror (脱敏后)
□ 导出 Jira/Linear 全部工单
□ 导出 Slack/钉钉/飞书消息
□ 导出 Notion/Confluence 全部页面
□ 导出邮件 mbox
□ 部署日志截屏
□ 告警响应记录打包
□ 事故复盘文档打包
□ 个人工作日志月度打包
□ 个人 GitHub Contribution 截图
□ GitHub 邮箱公开 commit 截图
□ 个税 APP / 社保 APP / 公积金 APP 截图
□ 银行工资到账短信截图
□ 同步到 2 个云盘(坚果云 + 百度网盘)
□ U 盘拷贝 + 信任家人物业
```

---

## 9. 与主 skills 联动

- **主 skills 的证据金字塔** 全部适用,程序员群体因产物数字化,**五星证据占比最高**。
- **主 skills 的 60 秒应急包** 同样适用,但额外追加:推 Git mirror、导出监控看板。
- **主 skills 的 7 张分清单** (在 evidence-checklist/) 可按本岗位裁剪。
- **scripts/evidence-scanner.sh** 已经覆盖程序员痕迹(`.git`、`.pem`、`.pypirc` 等)。

---

## 10. 关键术语

- **Personal Export** (Slack 等):个人数据导出申请,公司无法拒绝
- **贡献图 (Contribution Graph)**:GitHub 显示每日 commit,可作为在岗证据
- **PagerDuty 值班**:DevOps 的"打卡器",事件响应可证明加班
- **ADR (Architecture Decision Record)**:架构决策记录,可证明思考深度
- **Postmortem**:事故复盘文档,可证明对系统的掌控力

---

**版本**:v1.0(2026-07-02)
**联动物**:anti-violent-layoff-evidence 主 skills v1.0
