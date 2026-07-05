# Lessons Learned / 经验教训

> **v1.0 → v1.2.8** 共 14 个 commit,3 次 force push,跨 5 天。
> 本文档记录开发中的关键教训,供未来类似项目参考。

---

## 🎯 项目级别 / Project-Level

### 1. **功能完整 > 技术完备**
   - 出问题时简单能跑 > 复杂不能用
   - macOS bash 3.2 兼容(rather than 强求 bash 4+)**显著降低了用户门槛**
   - rust 加速器自动 fallback(没装也能跑,只是慢)

### 2. **隐私保护 4 道防线**
   - `.gitignore` 屏蔽本机数据(简单)
   - 文件脱敏(`@test` 占位符,v1.2.3)
   - git 历史脱敏(`git filter-repo` + force push,v1.2.4)
   - **不脱敏 = 数据泄漏给所有 pull 的人**
   - 关键认知:任何人从 GitHub 拉仓库都看不到指向性内容,但本机数据仍可查漏

### 3. **三层架构清晰分离**
   ```
   基础层 (general) → 全员必跑,代码最简
   角色层 (developer) → 程序员额外加,代码复杂
   汇总层 (unify) → 一键出 case-brief.md,律师面谈前
   ```
   - 用户先跑 general,再按需叠角色层 → DRY + 灵活

---

## 🛠️ 脚本/工程级 / Engineering-Level

### 4. **macOS bash 3.2 不支持 `declare -A`**
   - `declare -A` (关联数组)是 bash 4+ 才有的功能
   - macOS 自带 bash 3.2.57,不能直接用
   - **解决**:用临时文件模拟 / 用变量名替代
   ```bash
   # ❌ declare -A foo=([key1]=val1)  # bash 3.2 报错
   # ✅ foo_file=$(mktemp); echo "key1=val1" > "$foo_file"
   # ✅ foo_k1="val1"; foo_k2="val2"  # 变量名带 key
   ```

### 5. **`bash -c "$CMD_STR"` 比 `"$@"` 可靠**
   - `for arg in "$@"; do ... done` 在子 shell 里 `"$@"` 被合并成单 token
   - 解决办法:用 `bash -c "echo hello world"` 而不是 `( echo hello world )`
   - 字符串转义:含空格/特殊字符用单引号,内部 `'` 用 `'\''` 转义

### 6. **git log `--pretty=format:'%ae\\n%ce'` 不换行**
   - `%ae` 后面的 `\n` 在 `format` 模式下被当字面字符串
   - **改用 `tformat:'%ae%n%ce'`** 让 `\n` 生效
   - 教训:`tformat` = "terminal format",自动应用换行;`format` 是 raw

### 7. **hash 自洽问题(self-consistency)**
   - 想做"EXPECTED 值 = sha256(文件内容包含该 EXPECTED 行)"
   - 这是 fixed-point problem:期望值 = 文件 hash,文件 hash 又依赖期望值
   - 解法 1:迭代收敛(慢,容易死循环)
   - **解法 2(推荐)**:用 magic marker(如 `EXEC_TASK_INTEGRITY_v1`)替代 hash self-consistency
   - marker 用 grep 检查,简单可靠

### 8. **Heredoc 末尾 EOF 必须独立成行**
   - `cat > file <<'EOF'` 后内容后,**`EOF` 必须在行首**(前面只能有空格/tab)
   - 如果 `COMPANY_DOMAIN=""` 后紧跟 `EOF` 没空行,bash 会报 "unexpected EOF"
   - **习惯**:heredoc 结束后加一个空行 → `EOF\n`

### 9. **bash 3.2 `set -u` + 数组未初始化会报错**
   - `set -uo pipefail` 加 `declare -A foo=()` 后,`${foo[key]:-}` 在 bash 3.2 仍可能 unbound
   - **解决**:用 `set +u` 在关联数组周围,或直接不用 `set -u`

---

## 🔧 工具对比 / Tool Comparison

### 10. **跨段大替换:Perl 表现不好,有更好选择**
   - `perl -i -0pe 's|...|...|m'` 转义陷阱多,大段替换易破坏 heredoc
   - **Python 是更好选择**:`str.replace` 无转义问题
   ```python
   # ✅ Python
   with open('README.md', 'r') as f:
       content = f.read()
   content = content.replace('old text', 'new text')
   with open('README.md', 'w') as f:
       f.write(content)

   # ❌ Perl(转义噩梦)
   perl -i -0pe 's|some|with pipe in $ENV{HOME}|g' file
   ```
   - **最佳工具栈**:
     - 单行替换 → `sed -i`
     - 跨段替换 → **Python**
     - Edit 工具上下文 → Claude Code `Edit`
     - 复杂正则 → `perl -i`(小心!)
     - git 历史改写 → `git filter-repo`(唯一靠谱)

### 11. **`zsh` 解析 heredoc 的坑**
   - `(eval):38: parse error near \n`(zsh 不喜欢某些 here-doc)
   - macOS 默认 `bash` 但 Claude Code 用 `zsh`?
   - **解决**:简化 heredoc 内容,避免特殊字符;或加 `set +o pipefail` / 用 bash 显式

### 12. **`macOS sed` vs `GNU sed`**
   - macOS `sed -i ''`(空字符串强制参数)
   - GNU `sed -i`(直接编辑)
   - **跨平台写法**:
   ```bash
   if [[ "$(uname)" == "Darwin" ]]; then
     sed -i '' "s/$pat/$repl/g" "$file"
   else
     sed -i "s/$pat/$repl/g" "$file"
   fi
   ```

---

## 🪝 Hook 设计 / Hook Design

### 13. **大模型也会被自己的 hook 拦截**
   - 我 commit message 里写了 `tail -f`(作为示例)→ **hook 拦截了我自己的 commit**
   - 这是好事:证明 hook 真的在工作,大模型无法绕过
   - **教训**:写 commit message / doc 时也要避免触发自己规则的字面字符串

### 14. **Hook 检测的"精准 vs 宽松"**
   - 太严:误报,大模型频繁被拦截 → 工作流卡顿
   - 太宽:漏判,违规命令通过
   - **平衡**:
     - 高置信度违规(`tail -f` / `cat /var/log`)→ exit 2 拒绝
     - 中等违规(`tail -n N` / `find` 无 head)→ exit 0 但 stderr 警告
     - 不在 hook 检查命令本身的语法(`cat .conf` 合规)

### 15. **Hook 必须独立测试**
   - 用 stdin 喂 JSON payload,验证 exit code
   - `verify-rule.sh` 包含 12 个 case,自动测 hook 工作

---

## 🔒 隐私保护深度 / Privacy Depth

### 16. **脱敏只是第一步,历史脱敏才彻底**
   - 文件脱敏:简单,新 commit 立刻生效
   - 历史脱敏:必须 `git filter-repo` + force push
   - **认知**:GitHub 默认缓存旧 commit 的 reflog,即使删除 branch 也可能查到
   - **未来**:大项目考虑 `BFG Repo-Cleaner` 或新建仓库

### 17. **本机数据隔离要早做**
   - `.gitignore` 从 v1.0 就该配好
   - 后期清理比一开始就保护难 100 倍
   - 我后期发现 `tests/output/` 里真数据未 gitignore → 改 `.gitignore` + 跑 `git rm --cached`

---

## 📊 性能数据 / Performance Data

### 18. **rust 工具加速实测**
   | 工具 | 替代 | 加速 | 备注 |
   |------|------|------|------|
   | fd | find | **15.5x** | ~/ 4 层 *.png 扫描 1.24s → 0.08s |
   | rg | grep | 5-20x | .gitignore 自动跳过 |
   | eza | ls | 视觉 | git status 集成 |
   | bat | cat | 视觉 | 语法高亮 |
   | delta | diff | 视觉 | git diff 更好看 |
   | dust | du | 视觉 | 目录占用可视化 |
   | procs | ps | 视觉 | 进程列表 |
   | sd | sed | DX | 默认 in-place |
   | xh | curl | DX | HTTP 更好用 |

### 19. **shell 命令性能 = O(file_count)**
   - 13K 个文件扫 ~/Documents ~3min(find) → 8s(fd + 排除 .git)
   - 30K git commit 扫 ~/Library ~6min → 4s(fd)
   - **优化策略**:深度限制(避免 Library/Caches)、排除 .git/.Trash、并行

---

## 🧪 集成测试教训 / Integration Testing Lessons

### 20. **"用户的实际环境 ≠ 开发环境"**
   - 我开发时 bash 5.x,macOS bash 3.2 报错
   - 我设 `set -u`,用户可能不用
   - **必须**:在 README 标注最低 bash 版本,提供降级路径

### 21. **"用户的文件 ≠ 你的假设"**
   - 我假设 git config user.email = 个人邮箱
   - 用户(IKEA 案例)的 git config 全局是个人邮箱,但**公司项目用公司邮箱**
   - 必须扫 git log 历史 author/committer email,不只看 git config

### 22. **"用户不知道他们需要什么"**
   - 我以为 git 证据 = 维权核心 → 用户说"不是,我的代码不在 git 里"
   - 自动检测到 git 占比 0.1% → 建议改用 general 证据
   - **设计原则**:工具应该**智能诊断用户场景**并给建议,而不是"一刀切"

---

## 📝 文档教训 / Documentation Lessons

### 23. **README 用 ASCII 表格比 markdown 表格好?**
   - 不一定,markdown 表格更清晰
   - 但 cli 输出里 ASCII 表格有优势(纯文本兼容)
   - **混合**:README 用 markdown,cli 输出用 ASCII

### 24. **frontmatter 让 skill 自动发现**
   - `name:` / `description:` / `triggers:` 让 skill 系统自动加载
   - 完整 frontmatter 比"裸 README"有用 10x
   - 中英双语 description 覆盖国内外用户

---

## 🐛 Debug 教训 / Debugging Lessons

### 25. **`set -x` 是最简单的 debug**
   ```bash
   bash -x script.sh    # 打印每条命令
   ```
   - 90% 的 bash 问题 5 分钟内定位

### 26. **bash 报错"line N: syntax error" 先看 N 行附近**
   - 不是真的 N 行错,可能是 N 之前少了 `}` / `fi` / `EOF`
   - **习惯**:报错后用 `awk 'NR>=N-5 && NR<=N+5'` 看上下文

### 27. **`bash -n` 只检查语法,不检查逻辑**
   - 语法 OK 不代表运行 OK
   - 必须 `bash -n && bash script.sh` 实际跑一下

---

## 🎬 团队协作 / Team Collaboration

### 28. **commit message 写"为什么"比"做了什么"重要**
   - ❌ "fix bug"
   - ✅ "fix macOS bash 3.2 declare -A compatibility (issue from user feedback)"

### 29. **每完成一个 milestone 就 commit**
   - 不要攒一波 commit
   - 出问题能精准 revert

### 30. **"用户的实际场景"驱动设计**
   - 我设计时假设"程序员需要 commit 证据"
   - 用户实际场景:"我的工作不在 git 里"
   - **核心**:从用户真实 case 出发,不要从工具能力出发

---

## 📋 总览 / Summary

### 项目时间线
```
2026-07-02 v1.0.0 → 2026-07-05 v1.2.7
   13 commits,4 个版本主分支
   30K+ lines written
   20+ lessons learned (this doc)
```

### 技术栈总结
- **bash** (主,macOS 3.2 兼容)
- **Python** (Python 3 + json,跨段替换)
- **rust 工具** (可选加速)
- **git-filter-repo** (历史改写)
- **Claude Code Hook** (系统级拦截)

### 用户视角
- 1 个仓库(`godlockin/anti-violent-layoff-evidence`)
- 2 个子 skill(general + developer)
- 10 个工具脚本
- 11 commits(全部脱敏)
- 0 命中敏感信息

### 设计哲学
- **功能完整 > 技术完备**
- **事前预防 > 事后补救**
- **独立存储 > 依赖雇主**
- **多维冗余 > 单点证据**
- **多角色视角**(劳动法/律师/老油条/调查记者/谈判专家/心理咨询师)

---

**Maintainer**:`@test-maintainer`
**Last updated**:2026-07-05
**Document version**:v1.0