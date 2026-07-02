# Security Policy

**仓库地址 / Repository**:`https://github.com/your-org/anti-violent-layoff-evidence`  
**维护者 / Maintainer**:`@test-maintainer`  
**当前版本 / Current version**:`v1.0.0`

## 报告安全问题 / Reporting Security Issues

**请勿在公开 issue 中报告安全问题。**

如发现本仓库中的安全漏洞(如:某个脚本会泄露个人信息,某个文档错误引导用户做非法行为),请通过以下方式私下联系:

- **GitHub Security Advisories**:在仓库页面 → Security → Advisories → New
- **邮件**:见仓库的 `maintainer` 邮箱(在 GitHub Profile 中)

我们会在 7 个工作日内回复。

---

## 本仓库的安全原则 / Our Security Principles

### 我们承诺

1. **不教唆攻击** - 任何被报告的"教唆攻击雇主"内容会被立刻移除
2. **不教唆伪造** - 任何被报告的"教唆伪造证据"内容会被立刻移除
3. **不教唆泄密** - 任何"鼓励带走公司商业秘密"的内容会被移除
4. **不教唆报复** - 任何"报复性删库 / 勒索 / 骚扰"的内容会被移除
5. **法律引用准确** - 所有法条引用会标注具体出处,经律师背景贡献者 review

### 不在本仓库范围

- ❌ 任何具体公司/个人的黑名单(不名誉风险)
- ❌ 任何"如何绕过监控系统"的具体步骤
- ❌ 任何"如何删除公司数据"的具体步骤
- ❌ 任何"如何攻击雇主系统"的具体步骤
- ❌ 任何违反《刑法》《反不正当竞争法》的方法

### 在本仓库范围

- ✅ 保留**属于你的**工作产物副本
- ✅ 走合法维权路径(劳动监察、仲裁、诉讼)
- ✅ 主张合法权益(N、N+1、2N、加班费)
- ✅ 公开合法监督(媒体、行业组织、监管部门)
- ✅ 自动化、流程化取证,降低对个人记忆的依赖

---

## 个人信息保护 / Personal Information Protection

提交 PR 或 issue 时请注意:

❌ **不要**:
- 提交真实的身份证号、电话、邮箱、银行卡
- 提交真实公司名、HR 姓名(必要时脱敏)
- 提交真实客户信息、合同金额
- 提交未脱敏的工资条、个税记录

✅ **可以**:
- 用 `<your-company>` `<HR-Name>` 替代
- 用 `<masked-email>` 替代真实邮箱
- 用 `<phone-masked>` 替代真实电话

CI 会自动检查 PR 是否有疑似敏感信息,如有会要求脱敏。

---

## 脚本安全 / Script Safety

本仓库所有脚本遵循:

- 默认 **dry-run** 模式
- `--apply` 显式确认才执行修改
- 加密使用 `openssl aes-256-gcm`(strong cipher)
- 路径解析用 `find ... -print0` 防止注入
- 变量用 `${var:-default}` 防止 unset
- 关键操作有 `set -euo pipefail`

如果你发现某个脚本有:
- 路径遍历漏洞
- 命令注入风险
- 不安全加密(如同 `md5`、`sha1`、DES)
- 静默数据外发

请立刻报告,会优先修复。

---

## 依赖安全 / Dependency Security

本仓库**无第三方依赖**:
- 所有脚本用 bash + 操作系统自带工具
- 不引入 npm / pip / cargo 依赖
- 不联网下载任何代码
- 不调用任何外部 API(可选的"权利卫士"等是用户自选)

这意味着**没有供应链攻击面**。

---

## 致谢 / Acknowledgments

感谢所有负责任地报告问题的贡献者。
