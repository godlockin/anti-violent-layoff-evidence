#!/usr/bin/env bash
# git-evidence-scanner.sh - 遍历所有 git 仓库,导出 commit 元数据作为工作证据
# 适用岗位:程序员 / DevOps / 数据
# 用法:
#   bash scripts/git-evidence-scanner.sh                  # 扫描默认根目录
#   bash scripts/git-evidence-scanner.sh --root /path     # 自定义根
#   bash scripts/git-evidence-scanner.sh --since 2024-01-01
#   bash scripts/git-evidence-scanner.sh --author "Your Name"
#   bash scripts/git-evidence-scanner.sh --json
set -euo pipefail

EVIDENCE_ROOT="${EVIDENCE_ROOT:-$HOME/evidence}"
OUTDIR="$EVIDENCE_ROOT/git-evidence"
ROOT="$HOME"
SINCE=""
AUTHOR=""
JSON=0
EMAIL_FILTER=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)   ROOT="$2"; shift 2;;
    --since)  SINCE="$2"; shift 2;;
    --author) AUTHOR="$2"; shift 2;;
    --email)  EMAIL_FILTER="$2"; shift 2;;
    --output) OUTDIR="$2"; shift 2;;
    --json)   JSON=1; shift;;
    -h|--help) sed -n '2,15p' "$0"; exit 0;;
    *) echo "Unknown arg: $1" >&2; exit 1;;
  esac
done

mkdir -p "$OUTDIR"
stamp=$(date +%Y%m%d-%H%M%S)

if [[ -n "$SINCE" ]]; then
  echo "📅 起始时间: $SINCE"
  if ! date -d "$SINCE" >/dev/null 2>&1; then
    echo "ERROR: --since 格式应为 YYYY-MM-DD" >&2; exit 1
  fi
fi

# 查找所有 .git 目录
echo "🔍 扫描: $ROOT"
git_dirs=()
while IFS= read -r -d '' d; do
  git_dirs+=("$d")
done < <(find "$ROOT" -maxdepth 8 -type d -name ".git" 2>/dev/null -print0)

total=${#git_dirs[@]}
echo "📦 发现 $total 个 git 仓库"
if [[ $total -eq 0 ]]; then
  echo "⚠️  未发现 git 仓库。提示:可在公司项目下跑或调 --root"
  exit 0
fi

# 输出 master manifest
MASTER="$OUTDIR/git-commits-$stamp.csv"
{
  echo "repo,branch,commit_hash,author_name,author_email,committer_name,committer_email,author_date,commit_date,subject,files_changed,insertions,deletions"
} > "$MASTER"

processed=0
errored=0
for gd in "${git_dirs[@]}"; do
  repo="${gd%/.git}"
  # 优先用 worktree 仓库或裸仓库的父目录
  [[ -f "$repo/HEAD" ]] && [[ ! -d "$repo/.git" ]] && continue
  repo_path=$(cd "$repo" && pwd -P)
  echo "  → $repo_path"

  # 列出所有 branch
  branches=$(cd "$repo" && git branch -a 2>/dev/null | grep -v "^HEAD" | head -20)
  if [[ -z "$branches" ]]; then
    continue
  fi

  # 构建 git log 参数
  GIT_LOG_ARGS=(log --pretty=format:'%H|%an|%ae|%cn|%ce|%aI|%cI|%s' --numstat)
  [[ -n "$SINCE" ]]       && GIT_LOG_ARGS+=(--since "$SINCE")
  [[ -n "$AUTHOR" ]]      && GIT_LOG_ARGS+=(--author "$AUTHOR")
  [[ -n "$EMAIL_FILTER" ]] && GIT_LOG_ARGS+=(--author "$EMAIL_FILTER")

  # 对每个 branch 跑 log
  for br in $branches; do
    br_clean=$(echo "$br" | sed 's/^[* ]*//' | sed 's/^remotes\///')
    [[ -z "$br_clean" ]] && continue

    # 拉 log + numstat
    (cd "$repo" && git "${GIT_LOG_ARGS[@]}" "$br_clean" 2>/dev/null) > "$OUTDIR/.tmp.log" || {
      errored=$((errored+1))
      continue
    }

    # 解析:每个 commit header 行(以 | 分隔)后跟 numstat 行(直到空行)
    awk -v repo="$repo_path" -v br="$br_clean" -v out="$MASTER" '
    BEGIN { FS="|"; OFS="," }
    /^[a-f0-9]{40}\|/ {
      hash=$1; an=$2; ae=$3; cn=$4; ce=$5; ad=$6; cd=$7; subj=$8
      ins=0; del=0; files=0; in_files=0
      next
    }
    /^[0-9]+\t[0-9]+\t/ {
      in_files=1
      files++
      # 移除 tab,把 "-\t-\txxx" 也算
      n = split($0, parts, "\t")
      if (parts[1] != "-") ins += parts[1]
      if (parts[2] != "-") del += parts[2]
      next
    }
    /^$/ && in_files {
      # 输出 commit 行
      gsub(/"/, "", subj)
      printf "%s,%s,%s,%s,%s,%s,%s,%s,%s,\"%s\",%d,%d,%d\n", \
        repo, br, hash, an, ae, cn, ce, ad, cd, subj, files, ins, del
      printf "%s,%s,%s,%s,%s,%s,%s,%s,%s,\"%s\",%d,%d,%d\n", \
        repo, br, hash, an, ae, cn, ce, ad, cd, subj, files, ins, del >> out
      in_files=0
      next
    }
    ' "$OUTDIR/.tmp.log"

    processed=$((processed+1))
  done
done

rm -f "$OUTDIR/.tmp.log"

echo ""
echo "✅ 处理 $processed 个 branch, $errored 个错误"
echo "📄 输出: $MASTER"
echo "   行数: $(wc -l < "$MASTER")"

# JSON 输出
if [[ $JSON -eq 1 ]]; then
  json="$OUTDIR/git-commits-$stamp.json"
  {
    echo "{"
    echo "  \"scan_time\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\","
    echo "  \"root\": \"$ROOT\","
    echo "  \"since\": \"${SINCE:-null}\","
    echo "  \"author_filter\": \"${AUTHOR:-${EMAIL_FILTER:-null}}\","
    echo "  \"total_repos\": $total,"
    echo "  \"total_branches\": $processed,"
    echo "  \"csv_file\": \"$MASTER\""
    echo "}"
  } > "$json"
  echo "📄 JSON: $json"
fi

# 统计
echo ""
echo "=== 提交统计 ==="
if [[ -s "$MASTER" ]]; then
  echo "按作者 Top 10:"
  tail -n +2 "$MASTER" | awk -F',' '{print $4}' | sort | uniq -c | sort -rn | head -10
  echo ""
  echo "按日期(月)Top 10:"
  tail -n +2 "$MASTER" | awk -F',' '{print $9}' | cut -c1-7 | sort | uniq -c | sort -rn | head -10
fi

echo ""
echo "💡 提示:"
echo "  - 配合 scripts/evidence-collector.sh 收集 commit 邮件"
echo "  - 配合 scripts/evidence-aggregator.sh 汇总进 case-brief"
echo "  - 可在 ~/.config/avle.conf 配 author=排除 公司账号"
