#!/usr/bin/env bash
# unify-summarize.sh - 一键汇总所有收集器输出为 case-brief.md
# 用法:
#   bash scripts/unify-summarize.sh                    # 默认汇总
#   bash scripts/unify-summarize.sh --output PATH      # 指定输出
#   bash scripts/unify-summarize.sh --run-all          # 自动先跑所有 scanner/collector
#   bash scripts/unify-summarize.sh --package          # 加密打包输出
set -euo pipefail

EVIDENCE_ROOT="${EVIDENCE_ROOT:-$HOME/evidence}"
OUTPUT="$EVIDENCE_ROOT/case-brief.md"
RUN_ALL=0
PACKAGE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output) OUTPUT="$2"; shift 2;;
    --run-all) RUN_ALL=1; shift;;
    --package) PACKAGE=1; shift;;
    -h|--help) sed -n '2,12p' "$0"; exit 0;;
    *) echo "Unknown arg: $1" >&2; exit 1;;
  esac
done

cd "$(dirname "$0")/.."

if [[ $RUN_ALL -eq 1 ]]; then
  echo "=== 先跑所有收集器 ==="
  bash scripts/evidence-scanner.sh --json 2>/dev/null || true
  bash scripts/storage-evidence-scanner.sh --json 2>/dev/null || true
  bash scripts/holiday-sync.sh --print 2>/dev/null || true
  echo ""
fi

stamp=$(date +%Y%m%d-%H%M%S)
now=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# === 汇总 ===
{
  echo "# 证据汇总 / Case Brief"
  echo ""
  echo "> 生成时间: $now"
  echo "> 证据根目录: $EVIDENCE_ROOT"
  echo ""
  echo "## 0. 架构说明(general 基础 + 角色特化 + 统一汇总)"
  echo ""
  echo "本汇总整合 3 层证据:"
  echo "  - **基础层 (general)**:全员必跑 — 邮件/审批/沟通/纸面/财务"
  echo "  - **角色层**:程序员/测试/产品/devops 额外跑 — 代码/部署/工单"
  echo "  - **统一汇总层**(本文件):把所有 manifest 合并给律师"
  echo ""

  # === 1. 基础层:每周 hash manifest ===
  echo "## 1. 基础层 — 每周 Hash Manifest"
  echo ""
  if compgen -G "$EVIDENCE_ROOT/manifest.csv" >/dev/null || compgen -G "$EVIDENCE_ROOT/*/manifest.csv" >/dev/null; then
    total=$(find "$EVIDENCE_ROOT" -name "manifest.csv" -exec cat {} \; 2>/dev/null | grep -c "^[0-9a-f]" || true)
    echo "✅ 找到 manifest 记录: $total 条"
    echo ""
    echo "### 最新 manifest.csv(可附在律师材料后面)"
    echo ""
    if [[ -f "$EVIDENCE_ROOT/manifest.csv" ]]; then
      echo '```csv'
      head -20 "$EVIDENCE_ROOT/manifest.csv"
      echo '```'
    fi
  else
    echo "⚠️  暂无 manifest.csv,先跑: bash scripts/weekly-hash.sh"
  fi
  echo ""

  # === 2. 基础层:存储扫描结果 ===
  echo "## 2. 基础层 — 多存储工作文件扫描"
  echo ""
  if compgen -G "$EVIDENCE_ROOT/storage-evidence/storage-files-*.csv" >/dev/null; then
    latest=$(ls -t "$EVIDENCE_ROOT/storage-evidence"/storage-files-*.csv 2>/dev/null | head -1)
    if [[ -n "$latest" ]]; then
      total_files=$(tail -n +2 "$latest" | wc -l | tr -d ' ')
      echo "✅ 最近扫描: \`$latest\`"
      echo ""
      echo "文件数: $total_files"
      echo ""
      echo "### Top 10 扩展名"
      echo ""
      tail -n +2 "$latest" | awk -F',' '{
        gsub(/"/, "", $3)
        ext = $3
        if (ext) c[ext]++
      } END {
        for (e in c) print c[e], e
      }' | sort -rn | head -10 | awk '{printf "  - %s (%s)\n", $2, $1}'
      echo ""
      echo "### 存储根分布"
      echo ""
      tail -n +2 "$latest" | awk -F',' '{
        gsub(/"/, "", $7)
        c[$7]++
      } END {
        for (k in c) print c[k], k
      }' | sort -rn | head -10 | awk '{printf "  - %s: %s\n", $2, $1}'
    fi
  else
    echo "⚠️  暂无扫描结果,先跑: bash scripts/storage-evidence-scanner.sh"
  fi
  echo ""

  # === 3. 基础层:位置工作记录 ===
  echo "## 3. 基础层 — 位置工作记录 (WFH/客户现场/出差)"
  echo ""
  if [[ -f "$EVIDENCE_ROOT/location-log/locations.csv" ]]; then
    total=$(tail -n +2 "$EVIDENCE_ROOT/location-log/locations.csv" | wc -l | tr -d ' ')
    echo "✅ 位置记录: $total 条"
    echo ""
    echo "### 按位置类型统计(条数)"
    echo ""
    tail -n +2 "$EVIDENCE_ROOT/location-log/locations.csv" | awk -F',' '{c[$3]++} END {for (l in c) print c[l], l}' | sort -rn | awk '{printf "  - %s: %s 条\n", $2, $1}'
  else
    echo "⚠️  暂无位置记录,先跑: bash scripts/location-worklog.sh --auto"
  fi
  echo ""

  # === 4. 基础层:法定节假日 ===
  echo "## 4. 基础层 — 法定节假日(含调休)"
  echo ""
  if [[ -f "$EVIDENCE_ROOT/holidays/holidays-cn.csv" ]]; then
    legal=$(awk -F',' 'NR>1 && $4=="legal"' "$EVIDENCE_ROOT/holidays/holidays-cn.csv" | wc -l | tr -d ' ')
    adj=$(awk -F',' 'NR>1 && $4=="adjust"' "$EVIDENCE_ROOT/holidays/holidays-cn.csv" | wc -l | tr -d ' ')
    echo "✅ 法定节假日: $legal 天 / 调休: $adj 天"
    echo ""
    echo "加班费计算规则:"
    echo "  - 法定节假日 300%(国假当天)"
    echo "  - 周末 200%(公休日)"
    echo "  - 工作日延长 150%(延时)"
  else
    echo "⚠️  暂无节假日数据,先跑: bash scripts/holiday-sync.sh"
  fi
  echo ""

  # === 5. 角色层:程序员证据 ===
  echo "## 5. 角色层 — 程序员/测试/产品/DevOps"
  echo ""
  echo "> 仅程序员/技术岗生成"
  if compgen -G "$EVIDENCE_ROOT/git-evidence/git-commits-*.csv" >/dev/null; then
    latest=$(ls -t "$EVIDENCE_ROOT/git-evidence"/git-commits-*.csv 2>/dev/null | head -1)
    if [[ -n "$latest" ]]; then
      total_commits=$(tail -n +2 "$latest" | wc -l | tr -d ' ')
      echo "✅ Commit 记录: $total_commits 条"
      echo ""
      echo "### Top 5 作者"
      echo ""
      tail -n +2 "$latest" | awk -F',' '{gsub(/"/, "", $4); c[$4]++} END {for (a in c) print c[a], a}' | sort -rn | head -5 | awk '{printf "  - %s: %s commits\n", $2, $1}'
      echo ""
      echo "### Top 5 仓库(commit 数)"
      echo ""
      tail -n +2 "$latest" | awk -F',' '{gsub(/"/, "", $1); c[$1]++} END {for (r in c) print c[r], r}' | sort -rn | head -5 | awk '{printf "  - %s: %s\n", $2, $1}'
    fi
  else
    echo "⚠️  程序员岗额外跑: bash scripts/git-evidence-scanner.sh"
  fi
  echo ""

  # === 6. 已收集的 evidence 目录 ===
  echo "## 6. 已收集证据文件"
  echo ""
  if [[ -d "$EVIDENCE_ROOT" ]]; then
    total_files=$(find "$EVIDENCE_ROOT" -type f \( \
      -name "*.eml" -o -name "*.msg" -o -name "*.mbox" -o \
      -name "*.pdf" -o -name "*.jpg" -o -name "*.png" -o \
      -name "*.mp3" -o -name "*.mp4" -o -name "*.json" -o \
      -name "*.csv" -o -name "*.enc" -o -name "*.zip" -o -name "*.tar.gz" -o \
      -name "*.docx" -o -name "*.xlsx" -o -name "*.pptx" -o -name "*.txt" -o \
      -name "*.md" -o -name "*.ics" -o -name "*.har" -o -name "*.pcap" -o -name "*.pcapng" -o -name "*.sqlite" \
    \) 2>/dev/null | wc -l | tr -d ' ')

    total_size=$(find "$EVIDENCE_ROOT" -type f -exec stat -f %z {} + 2>/dev/null | awk '{s+=$1} END {print s+0}')
    human=$(numfmt --to=iec "$total_size" 2>/dev/null || echo "${total_size}B")

    echo "✅ 文件数: $total_files / 总大小: $human"
    echo ""
    echo "### 按类别统计"
    echo ""
    # 计数(用变量避免关联数组)
    cat_mail=0; cat_office=0; cat_image=0; cat_media=0; cat_structured=0; cat_archive=0
    for f in $(find "$EVIDENCE_ROOT" -type f \( \
      -name "*.eml" -o -name "*.msg" -o -name "*.mbox" -o -name "*.pst" -o -name "*.ost" \) 2>/dev/null); do
      cat_mail=$((cat_mail + 1))
    done
    for f in $(find "$EVIDENCE_ROOT" -type f \( \
      -name "*.pdf" -o -name "*.docx" -o -name "*.xlsx" -o -name "*.pptx" \) 2>/dev/null); do
      cat_office=$((cat_office + 1))
    done
    for f in $(find "$EVIDENCE_ROOT" -type f \( \
      -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" -o -name "*.heic" -o -name "*.webp" -o -name "*.bmp" -o -name "*.tiff" \) 2>/dev/null); do
      cat_image=$((cat_image + 1))
    done
    for f in $(find "$EVIDENCE_ROOT" -type f \( \
      -name "*.mp3" -o -name "*.m4a" -o -name "*.wav" -o -name "*.mp4" -o -name "*.mov" -o -name "*.avi" \) 2>/dev/null); do
      cat_media=$((cat_media + 1))
    done
    for f in $(find "$EVIDENCE_ROOT" -type f \( \
      -name "*.ics" -o -name "*.vcf" -o -name "*.har" -o -name "*.json" -o -name "*.sqlite" -o -name "*.pcap" -o -name "*.pcapng" \) 2>/dev/null); do
      cat_structured=$((cat_structured + 1))
    done
    for f in $(find "$EVIDENCE_ROOT" -type f \( \
      -name "*.enc" -o -name "*.zip" -o -name "*.tar.gz" -o -name "*.7z" \) 2>/dev/null); do
      cat_archive=$((cat_archive + 1))
    done

    [[ $cat_mail -gt 0 ]]      && echo "  - mail: $cat_mail"
    [[ $cat_office -gt 0 ]]    && echo "  - office: $cat_office"
    [[ $cat_image -gt 0 ]]     && echo "  - image: $cat_image"
    [[ $cat_media -gt 0 ]]     && echo "  - media: $cat_media"
    [[ $cat_structured -gt 0 ]] && echo "  - structured: $cat_structured"
    [[ $cat_archive -gt 0 ]]   && echo "  - archive: $cat_archive"
  else
    echo "⚠️  $EVIDENCE_ROOT 不存在"
  fi
  echo ""

  # === 7. 关键时间节点 ===
  echo "## 7. 关键时间节点(用户自填)"
  echo ""
  cat <<'EOF'
- 入职日期: ____
- 解除日期: ____
- 解除理由(对方陈述): ____
- 是否书面通知: □ 是 □ 否
- 工资: 月 ____ 元
- 工龄: ____ 年 ____ 月
- 年假: 已休 ____ / 法定 ____
- 加班: 月均 ____ 小时
- 主张诉求: □ N □ N+1 □ 2N □ 加班费 □ 未签合同二倍工资 □ 竞业补偿
- 关键人物:
  - HR: ____ (电话 ____)
  - 直属上级: ____
  - 部门负责人: ____
  - 同事证人: ____ (电话 ____)
- 律师: ____ (电话 ____)
- 12333 投诉: ____ (日期 ____)
EOF
  echo ""

  # === 8. 证据来源树 ===
  echo "## 8. 证据来源树"
  echo ""
  echo '```'
  if command -v tree >/dev/null 2>&1; then
    tree -L 3 -F --filelimit 30 "$EVIDENCE_ROOT" 2>/dev/null | head -80
  else
    find "$EVIDENCE_ROOT" -maxdepth 3 -type d 2>/dev/null | sort | sed 's|[^/]*/|  |g'
  fi
  echo '```'
  echo ""

  # === 9. 关键提醒 + 动态 checklist ===
  echo "## 9. 律师面谈前 checklist (动态生成)"
  echo ""
  echo "### ✅ 已有(自动检测)"
  echo ""
  # 动态勾选(根据实际文件)
  [[ -f "$EVIDENCE_ROOT/case-brief.md" ]] && echo "- [x] case-brief.md 已生成(本文件)" || echo "- [ ] case-brief.md 已生成(本文件)"
  if compgen -G "$EVIDENCE_ROOT/manifest.csv" >/dev/null || compgen -G "$EVIDENCE_ROOT/*/manifest.csv" >/dev/null; then
    n=$(find "$EVIDENCE_ROOT" -name "manifest.csv" 2>/dev/null | wc -l | tr -d ' ')
    echo "- [x] manifest.csv 已生成 ($n 个)"
  else
    echo "- [ ] manifest.csv 已生成(0 个)"
  fi
  if compgen -G "$EVIDENCE_ROOT/storage-evidence/*.csv" >/dev/null; then
    n=$(find "$EVIDENCE_ROOT" -name "*.csv" -path "*/storage-evidence/*" 2>/dev/null | wc -l | tr -d ' ')
    files_n=$(awk -F',' 'NR>1' "$EVIDENCE_ROOT"/storage-evidence/*.csv 2>/dev/null | wc -l | tr -d ' ')
    echo "- [x] 多存储工作文件已扫描 ($files_n 个文件,$n 个 CSV)"
  else
    echo "- [ ] 多存储工作文件扫描 (未跑:bash scripts/storage-evidence-scanner.sh)"
  fi
  if compgen -G "$EVIDENCE_ROOT/git-evidence/*.csv" >/dev/null; then
    n=$(awk -F',' 'NR>1' "$EVIDENCE_ROOT"/git-evidence/*.csv 2>/dev/null | wc -l | tr -d ' ')
    echo "- [x] git commit 已遍历 ($n 个 commit)"
  else
    echo "- [ ] git commit 遍历 (未跑:bash scripts/git-evidence-scanner.sh)"
  fi
  if [[ -f "$EVIDENCE_ROOT/holidays/holidays-cn.csv" ]]; then
    h_n=$(awk -F',' 'NR>1 && $4=="legal"' "$EVIDENCE_ROOT/holidays/holidays-cn.csv" | wc -l | tr -d ' ')
    echo "- [x] 法定节假日已同步 ($h_n 天)"
  else
    echo "- [ ] 法定节假日同步 (未跑:bash scripts/holiday-sync.sh)"
  fi
  if [[ -f "$EVIDENCE_ROOT/location-log/locations.csv" ]]; then
    n=$(tail -n +2 "$EVIDENCE_ROOT/location-log/locations.csv" | wc -l | tr -d ' ')
    if [[ $n -gt 1 ]]; then
      echo "- [x] 位置记录已建立 ($n 条)"
    else
      echo "- [~] 位置记录只有 1 条 — **建议每天 9/13/18 跑 --auto 持续记录**"
    fi
  else
    echo "- [ ] 位置记录 (未跑:bash scripts/location-worklog.sh --auto)"
  fi
  echo ""

  echo "### 📋 待办(手动作业)"
  echo ""
  cat <<'EOF'
- [ ] 关键证据已公证(权利卫士 / 区块链 / 线下公证处)
- [ ] 已打印纸质备份 1 份
- [ ] 已拷贝 U 盘 + 信任家人物业
- [ ] 已加密打包:bash scripts/evidence-collector.sh --apply
- [ ] 已准备身份证 + 工资条 + 合同副本
- [ ] 已准备:个人邮箱 / 个税 APP / 社保 APP / 公积金 APP 截图
- [ ] 已咨询法律援助中心(免费,12348)
- [ ] 已查询 12333 政策与时效
- [ ] 已了解 1 年仲裁时效
- [ ] 1 年时效警告:剩余 ____ 天
EOF

  # === 10. 缺口分析(根据实际状态给出建议) ===
  echo ""
  echo "## 10. 证据缺口分析(根据本次扫描)"
  echo ""

  # 分析 git 占比
  if compgen -G "$EVIDENCE_ROOT/git-evidence/*.csv" >/dev/null; then
    total=$(awk -F',' 'NR>1' "$EVIDENCE_ROOT"/git-evidence/*.csv 2>/dev/null | wc -l | tr -d ' ')
    my_n=$(awk -F',' 'NR>1 && $15=="1"' "$EVIDENCE_ROOT"/git-evidence/*.csv 2>/dev/null | wc -l | tr -d ' ')
    if [[ $total -gt 0 ]]; then
      pct=$(awk "BEGIN {printf \"%.1f\", 100*$my_n/$total}")
      if [[ $(awk "BEGIN {print ($pct < 5)}") -eq 1 ]]; then
        echo "### ⚠️  你的 git commit 占比 < 5% ($my_n / $total = $pct%)"
        echo ""
        echo "**结论**:你的代码贡献可能**不在 git 里**。你的岗位可能不是纯程序员(数据/分析/咨询/管理/设计)。"
        echo ""
        echo "**建议**:**改用基础层 (general) 证据为主**,包括:"
        echo "- 邮件全量备份(Thunderbird/Outlook 拉 mbox)"
        echo "- 个税 / 社保 / 公积金 APP 截图(每月)"
        echo "- 位置记录(每天 9/13/18 跑 --auto)"
        echo "- 沟通记录(钉钉/飞书/企微 导出)"
        echo ""
        echo "详见 \`skills/general/SKILL.md\`"
      elif [[ $(awk "BEGIN {print ($pct > 80)}") -eq 1 ]]; then
        echo "### ✅ 你的 git commit 占比 > 80%($my_n / $total = $pct%)"
        echo ""
        echo "**结论**:git 证据是维权核心。推荐用 \`skills/developer/SKILL.md\` 的所有手段。"
        echo ""
        echo "**下一步**:加 PR 邮件 / Code Review 截图 / 部署记录等(参见 developer skill §1-3)"
      else
        echo "### 你的 git commit 占比: $pct%($my_n / $total)"
        echo ""
        echo "混合场景:**git 证据 + 通用证据并用**"
        echo "- 程序员部分:developer/SKILL.md"
        echo "- 非 git 工作:general/SKILL.md"
      fi
    fi
  fi

  # 存储扫描覆盖
  echo ""
  echo "### 📂 存储扫描覆盖"
  echo ""
  if compgen -G "$EVIDENCE_ROOT/storage-evidence/*.csv" >/dev/null; then
    total_files=$(awk -F',' 'NR>1' "$EVIDENCE_ROOT"/storage-evidence/*.csv 2>/dev/null | wc -l | tr -d ' ')
    total_size=$(awk -F',' 'NR>1 {gsub(/"/, "", $0); s+=$4} END {print s+0}' "$EVIDENCE_ROOT"/storage-evidence/*.csv 2>/dev/null)
    human=$(numfmt --to=iec "$total_size" 2>/dev/null || echo "${total_size}B")
    echo "- 已扫描文件: **$total_files** 个,总大小 **$human**"
    echo ""
    echo "**存储根分布**:"
    awk -F',' 'NR>1 {gsub(/"/, "", $7); c[$7]++} END {for (k in c) printf "  - %s: %s 个文件\n", k, c[k]}' "$EVIDENCE_ROOT"/storage-evidence/*.csv | sort -t: -k2 -rn | head -5
  else
    echo "- ⚠️  未扫描,跑:bash scripts/storage-evidence-scanner.sh"
  fi
  echo ""
  echo "**建议覆盖**:"
  echo "- 公司配的 Mac 本地文件 ✓ (本工具已扫)"
  echo "- OneDrive 个人版: 需安装并登录 OneDrive 客户端"
  echo "- 坚果云 / 百度网盘: 需安装并登录客户端"
  echo "- 移动硬盘 / U 盘: 插入后自动出现在 \`/Volumes/\` (macOS) 或 \`/mnt/\` (Linux)"
  echo "- 工作手机: 单独跑此脚本并指定 \`--paths\`"

} > "$OUTPUT"

echo "✅ Case Brief 已生成: $OUTPUT"
echo "📊 文件数: $(wc -l < "$OUTPUT") 行"

# 加密打包
if [[ $PACKAGE -eq 1 ]]; then
  pkg_dir="$(dirname "$OUTPUT")"
  cd "$pkg_dir"
  archive="case-brief-$stamp.tar.gz.enc"
  echo ""
  echo "🔐 加密打包(密码提示)..."
  if [[ -t 0 ]]; then
    echo -n "请输入打包密码(可回车跳过): "
    read -r -s PWD_INPUT
    echo ""
  else
    PWD_INPUT=""
  fi
  if [[ -n "$PWD_INPUT" ]]; then
    tar -czf - "$(basename "$OUTPUT")" 2>/dev/null | \
      openssl enc -aes-256-gcm -salt -pbkdf2 -pass "pass:$PWD_INPUT" -out "$archive"
    echo "✅ 加密归档: $pkg_dir/$archive"
  fi
fi

echo ""
echo "💡 下一步:"
echo "  1. 把 case-brief.md 给律师看"
echo "  2. 配合 scripts/evidence-collector.sh --apply 加密打包全部 evidence"
echo "  3. 配合 templates/incident-runbook.md 检查 60 秒应急包"
