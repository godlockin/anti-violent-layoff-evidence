#!/usr/bin/env bash
# evidence-aggregator.sh - 汇总 manifest + 生成证据清单报告 (PDF/MD)
# 把所有 manifest.csv 合并,出 case-brief.md 概览
# 用法: bash scripts/evidence-aggregator.sh [--root PATH] [--output PATH]
set -euo pipefail

EVIDENCE_ROOT="${EVIDENCE_ROOT:-$HOME/evidence}"
OUTPUT="$EVIDENCE_ROOT/case-brief.md"
[[ "${1:-}" == "--root" ]] && EVIDENCE_ROOT="$2" && shift 2
[[ "${1:-}" == "--output" ]] && OUTPUT="$2" && shift 2

echo "=== Evidence Aggregator ==="
echo "源: $EVIDENCE_ROOT"
echo "输出: $OUTPUT"

if [[ ! -d "$EVIDENCE_ROOT" ]]; then
  echo "ERROR: $EVIDENCE_ROOT 不存在"
  exit 1
fi

# 1. 收集所有 manifest.csv
manifests=()
while IFS= read -r -d '' m; do
  manifests+=("$m")
done < <(find "$EVIDENCE_ROOT" -type f -name "manifest.csv" -print0 2>/dev/null)

if [[ ${#manifests[@]} -eq 0 ]]; then
  echo "⚠️  未发现 manifest.csv,请先运行 weekly-hash.sh 或 evidence-collector.sh"
  exit 1
fi

echo "发现 ${#manifests[@]} 个 manifest"

# 2. 收集所有证据文件
evidence_files=()
while IFS= read -r -d '' f; do
  evidence_files+=("$f")
done < <(find "$EVIDENCE_ROOT" -type f \( \
  -name "*.eml" -o -name "*.msg" -o -name "*.mbox" -o \
  -name "*.pdf" -o -name "*.jpg" -o -name "*.png" -o \
  -name "*.mp3" -o -name "*.mp4" -o -name "*.json" -o \
  -name "*.csv" -o -name "*.enc" -o -name "*.zip" -o -name "*.tar.gz" -o \
  -name "*.docx" -o -name "*.xlsx" -o -name "*.pptx" -o -name "*.txt" -o \
  -name "*.md" \) -print0 2>/dev/null)

total_files=${#evidence_files[@]}
total_size=0
for f in "${evidence_files[@]}"; do
  s=$(stat -f %z "$f" 2>/dev/null || stat -c %s "$f" 2>/dev/null || echo 0)
  total_size=$((total_size + s))
done

# 3. 按类别分组
declare -A cat_count
declare -A cat_size
for f in "${evidence_files[@]}"; do
  rel="${f#$EVIDENCE_ROOT/}"
  case "$rel" in
    incident/*) cat="incident";;
    2[0-9][0-9][0-9]-Q*|2[0-9][0-9][0-9]-W*|2[0-9][0-9][0-9]-[0-1][0-9]*) cat="periodic";;
    timestamp/*) cat="timestamp";;
    公证*|notarization/*) cat="notarized";;
    *) cat="other";;
  esac
  s=$(stat -f %z "$f" 2>/dev/null || stat -c %s "$f" 2>/dev/null || echo 0)
  cat_count[$cat]=$((${cat_count[$cat]:-0} + 1))
  cat_size[$cat]=$((${cat_size[$cat]:-0} + s))
done

# 4. 输出 case-brief.md
{
  echo "# 证据汇总清单 / Case Brief"
  echo ""
  echo "> 生成时间: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "> 证据根目录: $EVIDENCE_ROOT"
  echo "> 总文件: $total_files"
  echo "> 总大小: $(numfmt --to=iec $total_size 2>/dev/null || echo ${total_size}B)"
  echo ""
  echo "## 1. 概览"
  echo ""
  echo "| 类别 | 文件数 | 大小 | 备注 |"
  echo "|------|--------|------|------|"
  echo "| incident (事发) | ${cat_count[incident]:-0} | $(numfmt --to=iec ${cat_size[incident]:-0} 2>/dev/null || echo "0B") | 暴力清退相关 |"
  echo "| periodic (周期) | ${cat_count[periodic]:-0} | $(numfmt --to=iec ${cat_size[periodic]:-0} 2>/dev/null || echo "0B") | 周/月/季度证据 |"
  echo "| timestamp (时间戳) | ${cat_count[timestamp]:-0} | $(numfmt --to=iec ${cat_size[timestamp]:-0} 2>/dev/null || echo "0B") | TSA/区块链 |"
  echo "| notarized (公证) | ${cat_count[notarized]:-0} | $(numfmt --to=iec ${cat_size[notarized]:-0} 2>/dev/null || echo "0B") | 公证处存证 |"
  echo "| other | ${cat_count[other]:-0} | $(numfmt --to=iec ${cat_size[other]:-0} 2>/dev/null || echo "0B") | 其他 |"
  echo ""
  echo "## 2. 周期证据(默认时序)"
  echo ""
  if [[ ${cat_count[periodic]:-0} -gt 0 ]]; then
    find "$EVIDENCE_ROOT" -mindepth 1 -maxdepth 1 -type d \( -name "2[0-9][0-9][0-9]-Q*" -o -name "2[0-9][0-9][0-9]-W*" -o -name "2[0-9][0-9][0-9]-[0-1][0-9]*" \) 2>/dev/null | sort | while read -r d; do
      n=$(find "$d" -type f 2>/dev/null | wc -l | tr -d ' ')
      echo "- $(basename "$d"): $n 个文件"
    done
  else
    echo "(无)"
  fi
  echo ""
  echo "## 3. 事发当日证据"
  echo ""
  if [[ ${cat_count[incident]:-0} -gt 0 ]]; then
    find "$EVIDENCE_ROOT/incident" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort | while read -r d; do
      echo "### $(basename "$d")"
      echo ""
      find "$d" -type f | sort | while read -r f; do
        rel="${f#$EVIDENCE_ROOT/}"
        size=$(stat -f %z "$f" 2>/dev/null || stat -c %s "$f" 2>/dev/null || echo 0)
        echo "- \`$rel\` ($(numfmt --to=iec $size 2>/dev/null || echo "${size}B"))"
      done
      echo ""
    done
  else
    echo "(无)"
  fi
  echo ""
  echo "## 4. 公证 / 时间戳固化"
  echo ""
  if [[ ${cat_count[notarized]:-0} -gt 0 ]] || [[ ${cat_count[timestamp]:-0} -gt 0 ]]; then
    find "$EVIDENCE_ROOT" -type f \( -path "*/timestamp/*" -o -path "*/公证*" -o -path "*/notarization/*" -o -name "*.tsr" -o -name "*公证*.pdf" -o -name "*公证书*" \) 2>/dev/null | sort | while read -r f; do
      rel="${f#$EVIDENCE_ROOT/}"
      echo "- \`$rel\`"
    done
  else
    echo "(无)"
  fi
  echo ""
  echo "## 5. Hash 登记总表"
  echo ""
  for m in "${manifests[@]}"; do
    echo "### \`${m#$EVIDENCE_ROOT/}\`"
    echo ""
    head -1 "$m" 2>/dev/null
    tail -n +2 "$m" 2>/dev/null | head -20
    echo ""
  done
  echo "## 6. 关键法律事实(用户自填)"
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
  - 同事证人: ____
- 律师: ____ (电话 ____)
EOF
  echo ""
  echo "## 7. 备注"
  echo ""
  echo "(自由补充,作为律师面谈前摘要)"
} > "$OUTPUT"

echo "✅ Case Brief 已生成: $OUTPUT"
echo "📋 文件数: $total_files | 大小: ${total_size}B"
