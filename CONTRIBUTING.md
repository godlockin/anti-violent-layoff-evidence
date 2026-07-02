# Contributing to Anti-Violent-Layoff Evidence

> 感谢你愿意贡献。请先阅读 [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) 和本指南。

## 🎯 我们需要什么 / What We Need

| 类型 | 说明 |
|------|------|
| **新岗位 skill** | 医生 / 律师 / 教师 / 公务员 / 销售 / 财务 / 法务 等 |
| **新法域** | 美国 / 港 / 新 / 英 / 德 法律体系适配 |
| **新工具脚本** | 自动化导出、证据校验、PDF 生成 |
| **翻译** | 英文 / 繁体中文 / 其他语言 |
| **案例脱敏** | 真实案例(脱敏后)放进 evidence-cases/ |
| **文档完善** | 配图、流程图、视频讲解 |
| **漏洞 / 不准确** | 法律引用错误、流程漏洞、误信息 |

## ⚠️ 红线 / Red Lines

❌ **不接受**:
- 任何教唆攻击、报复、敲诈的内容
- 任何教唆伪造证据、删公司数据、窃取商业秘密的内容
- 任何针对具体公司/个人的指名道姓的攻击性内容
- 任何未经核实的"法律知识",请引用具体法条
- 任何歧视性、煽动性内容

✅ **欢迎**:
- 客观中性的证据保留方法
- 具体法条引用(注明出处)
- 真实案例(脱敏到无法识别当事人)
- 不同法域的本土化适配
- 自动化、流程化建议

## 🛠️ 贡献流程 / How to Contribute

### 1. 提交 issue

- **Bug / 不准确**:在 issue 中说明哪条/哪个文件,以及你的修正
- **新功能**:先在 issue 讨论,达成共识再提 PR
- **法律疑问**:在 issue 中提出,会有法律背景的贡献者协助

### 2. Fork + Pull Request

```bash
# 1. Fork
# 2. Clone
git clone https://github.com/<your-name>/anti-violent-layoff-evidence.git
cd anti-violent-layoff-evidence

# 3. 新建分支
git checkout -b feat/medic-skill      # 新功能
# 或
git checkout -b fix/typo-SKILL-md     # 修复

# 4. 修改 + 提交
git add .
git commit -m "feat(skills/medic): 添加医生岗位 evidence skill"

# 5. 推送到 fork
git push origin feat/medic-skill

# 6. 在 GitHub 上发起 PR
```

### 3. 提交规范 (Conventional Commits)

```
feat: 新功能
fix: 修复
docs: 文档
style: 格式(无逻辑变化)
refactor: 重构
test: 测试
chore: 构建/工具变更
```

格式: `type(scope): subject`

示例:
- `feat(skills/medic): 添加医生岗位 evidence skill`
- `fix(scripts/collector): 修复 #123 描述的路径展开问题`
- `docs(SKILL): 修正《劳动法》§39 引用`

### 4. 提交前自检

- [ ] 我没有添加任何教唆攻击、报复、敲诈、伪造的内容
- [ ] 所有法律引用都有具体出处
- [ ] 所有脚本都通过了 `bash -n` 语法检查
- [ ] 所有 README 的格式与现有保持一致
- [ ] 我没有添加敏感信息(身份证号、电话、邮箱)
- [ ] 我没有在示例中使用真实公司名/人名

## 🧪 测试 / Testing

```bash
# 语法检查所有脚本
for f in scripts/*.sh; do bash -n "$f" || exit 1; done

# 集成测试(如果有)
bash tests/integration/test.sh

# 验证 SKILL.md 格式
# (见 scripts/lint-skill.sh 如果存在)
```

## 📝 Style Guide

### Markdown
- 标题用 ATX 风格(`#` 而非 `===`)
- 列表用 `-` 而非 `*`
- 代码块带语言标识
- 中英文之间留一个空格

### Shell
- `set -euo pipefail` 在文件头
- 变量用 `"${var:-default}"` 形式
- 路径用 `"$HOME/path"` 而非 `~/path`(脚本中)
- 函数用 `local` 声明局部变量

### YAML / JSON
- 2 空格缩进
- 不要 trailing whitespace

## ❓ 问题 / Questions

- 在 issue 中 @ maintainer
- 在 Discussions 中发起讨论(如果开了)
- 邮件:见 [SECURITY.md](SECURITY.md) 关于安全问题的报告

---

**感谢贡献!Together we make the workplace more transparent.**
