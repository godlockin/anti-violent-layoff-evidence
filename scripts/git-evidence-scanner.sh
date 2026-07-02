#!/usr/bin/env bash
# git-evidence-scanner.sh - 遍历所有 git 仓库,导出 commit 元数据作为工作证据
# 适用岗位:程序员 / DevOps / 数据
# 用法:
#   bash scripts/git-evidence-scanner.sh                  # 扫描默认根目录
#   bash scripts/git-evidence-scanner.sh --root /path     # 自定义根
#   bash scripts/git-evidence-scanner.sh --since 2024-01-01
#   bash scripts/git-evidence-scanner.sh --author "Your Name"
#   bash scripts/git-evidence-scanner.sh --my-email       # 只统计自己的 commit
#   bash scripts/git-evidence-scanner.sh --account-report # 输出账号分析报告
#   bash scripts/git-evidence-scanner.sh --json
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/config.sh
source "$SCRIPT_DIR/lib/config.sh"

EVIDENCE_ROOT="${AVLE_EVIDENCE_ROOT:-$HOME/evidence}"
OUTDIR="$EVIDENCE_ROOT/git-evidence"
ROOT="$HOME"
SINCE=""
AUTHOR=""
JSON=0
EMAIL_FILTER=""
MY_EMAIL_ONLY=0
ACCOUNT_REPORT=0
COMPANY_DOMAIN="${AVLE_COMPANY_DOMAIN:-}"

# 兼容旧参数
[[ "${1:-}" == "--json" ]] && JSON=1 && shift

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)           ROOT="$2"; shift 2;;
    --since)          SINCE="$2"; shift 2;;
    --author)         AUTHOR="$2"; shift 2;;
    --email)          EMAIL_FILTER="$2"; shift 2;;
    --company-domain) COMPANY_DOMAIN="$2"; shift 2;;
    --my-email)       MY_EMAIL_ONLY=1; shift;;
    --account-report) ACCOUNT_REPORT=1; shift;;
    --output)         OUTDIR="$2"; shift 2;;
    --json)           JSON=1; shift;;
    --init-config)    write_default_config; exit 0;;
    -h|--help)        sed -n '2,18p' "$0"; exit 0;;
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
  echo "repo,branch,commit_hash,author_name,author_email,committer_name,committer_email,author_date,commit_date,subject,files_changed,insertions,deletions,account_group,is_mine"
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
    awk -v repo="$repo_path" -v br="$br_clean" -v out="$MASTER" -v company="$COMPANY_DOMAIN" -v my_emails="$AVLE_MY_EMAILS" '
    BEGIN { FS="|"; OFS="," }
    function classify_account(email,    dom, e_lc) {
      e_lc = tolower(email)
      # 公司账号:含公司域名
      if (company != "" && index(e_lc, tolower(company)) > 0) return "COMPANY"
      # 个人账号:gmail / qq / 163 / outlook / github noreply 等
      if (match(e_lc, /@(gmail|qq|163|outlook|hotmail|yahoo|foxmail|126)\.com/)) return "PERSONAL"
      if (index(e_lc, "users.noreply.github.com") > 0) return "PERSONAL"
      # 学术:.edu / .ac. / campus.
      if (match(e_lc, /(\.edu|\.ac\.|campus\.)/)) return "EDU"
      # 其他公司
      return "OTHER_CORP"
    }
    function is_mine(email,    me, i, n, arr) {
      if (my_emails == "") return 0
      n = split(my_emails, arr, " ")
      for (i=1; i<=n; i++) {
        me = arr[i]
        if (me != "" && index(email, me) > 0) return 1
      }
      return 0
    }
    /^[a-f0-9]{40}\|/ {
      hash=$1; an=$2; ae=$3; cn=$4; ce=$5; ad=$6; cd=$7; subj=$8
      ins=0; del=0; files=0; in_files=0
      next
    }
    /^[0-9]+\t[0-9]+\t/ {
      in_files=1
      files++
      n = split($0, parts, "\t")
      if (parts[1] != "-") ins += parts[1]
      if (parts[2] != "-") del += parts[2]
      next
    }
    /^$/ && in_files {
      gsub(/"/, "", subj)
      ag = classify_account(ae)
      im = is_mine(ae)
      line = sprintf("%s,%s,%s,%s,%s,%s,%s,%s,%s,\"%s\",%d,%d,%d,%s,%d", \
        repo, br, hash, an, ae, cn, ce, ad, cd, subj, files, ins, del, ag, im)
      print line
      print line >> out
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

# === 账号分析(自动) ===
echo ""
echo "=== 账号分组(基于 email domain) ==="
if [[ -s "$MASTER" ]]; then
  tail -n +2 "$MASTER" | awk -F',' '{
    gsub(/"/, "", $0)
    print $14
  }' | sort | uniq -c | sort -rn | head -10
fi

# === 自己的 commit(--my-email 或自动) ===
if [[ $MY_EMAIL_ONLY -eq 1 ]] || [[ -n "$AVLE_MY_EMAILS" ]]; then
  my_n=$(tail -n +2 "$MASTER" | awk -F',' '{
    gsub(/"/, "", $0)
    if ($15 == "1") c++
  } END { print c+0 }')
  echo ""
  echo "=== 你的 commit(基于 ~/.config/avle.conf MY_EMAILS) ==="
  echo "总数: $my_n"
  if [[ $my_n -gt 0 ]]; then
    echo ""
    echo "按账号组分类:"
    tail -n +2 "$MASTER" | awk -F',' '{
      gsub(/"/, "", $0)
      if ($15 == "1") print $14
    }' | sort | uniq -c | sort -rn
  fi
fi

# === 完整 account-report ===
if [[ $ACCOUNT_REPORT -eq 1 ]]; then
  RPT="$OUTDIR/account-report-$stamp.md"
  {
    echo "# Git 账号分析报告 / Git Account Analysis Report"
    echo ""
    echo "> 生成时间: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "> 数据源: \`$MASTER\`"
    echo ""
    echo "## 1. 账号组分布"
    echo ""
    tail -n +2 "$MASTER" | awk -F',' '{
      gsub(/"/, "", $0)
      print $14
    }' | sort | uniq -c | sort -rn | awk '{printf "  - **%s**: %d commits\n", $2, $1}'
    echo ""
    echo "## 2. 你的 commit (MY_EMAILS)"
    echo ""
    if [[ -z "$AVLE_MY_EMAILS" ]]; then
      echo "⚠️  未配置 MY_EMAILS"
      echo "1) 编辑 \`~/.config/avle.conf\` 填入你的邮箱"
      echo "2) 或跑: \`bash scripts/git-evidence-scanner.sh --init-config\`"
    else
      echo "匹配邮箱: \`$AVLE_MY_EMAILS\`"
      echo ""
      my_n=$(tail -n +2 "$MASTER" | awk -F',' '{
        gsub(/"/, "", $0)
        if ($15 == "1") c++
      } END { print c+0 }')
      echo "你的 commit 总数: **$my_n**"
      echo ""
      echo "### 按账号组分类"
      tail -n +2 "$MASTER" | awk -F',' '{
        gsub(/"/, "", $0)
        if ($15 == "1") print $14
      }' | sort | uniq -c | sort -rn | awk '{printf "  - %s: %d\n", $2, $1}'
      echo ""
      echo "### Top 10 你的仓库"
      tail -n +2 "$MASTER" | awk -F',' '{
        gsub(/"/, "", $0)
        if ($15 == "1") print $1
      }' | sort | uniq -c | sort -rn | head -10 | awk '{printf "  - %d commits: %s\n", $1, $2}'
    fi
    echo ""
    echo "## 3. 公司账号详细 (COMPANY_DOMAIN=\`${COMPANY_DOMAIN:-未配置}\`)"
    echo ""
    if [[ -z "$COMPANY_DOMAIN" ]]; then
      echo "⚠️  未配置 COMPANY_DOMAIN,无法识别公司 commit"
      echo "在 \`~/.config/avle.conf\` 设:"
      echo '```'
      echo 'COMPANY_DOMAIN="your-company.com"'
      echo '```'
    else
      company_n=$(tail -n +2 "$MASTER" | awk -F',' -v d="$COMPANY_DOMAIN" '{
        gsub(/"/, "", $0)
        if (tolower($5) ~ tolower(d)) c++
      } END { print c+0 }')
      echo "公司账号 commit 总数: **$company_n**"
      echo ""
      echo "### 公司账号使用的仓库"
      tail -n +2 "$MASTER" | awk -F',' -v d="$COMPANY_DOMAIN" '{
        gsub(/"/, "", $0)
        if (tolower($5) ~ tolower(d)) print $1
      }' | sort | uniq -c | sort -rn | head -10 | awk '{printf "  - %d commits: %s\n", $1, $2}'
    fi
    echo ""
    echo "## 4. 时间分布 (你的 commit)"
    echo ""
    if [[ -n "$AVLE_MY_EMAILS" ]]; then
      tail -n +2 "$MASTER" | awk -F',' '{
        gsub(/"/, "", $0)
        if ($15 == "1") print substr($9, 1, 7)
      }' | sort | uniq -c | sort -rn | head -12 | awk '{printf "  - %s: %d commits\n", $2, $1}'
    else
      echo "(跳过:未配置 MY_EMAILS)"
    fi
    echo ""
    echo "## 5. ⚠️ 重要发现"
    echo ""
    # 自己的 commit 占比
    if [[ -n "$AVLE_MY_EMAILS" ]]; then
      total=$(tail -n +2 "$MASTER" | wc -l | tr -d ' ')
      my_n=$(tail -n +2 "$MASTER" | awk -F',' '{
        gsub(/"/, "", $0)
        if ($15 == "1") c++
      } END { print c+0 }')
      pct=$(awk "BEGIN {printf \"%.1f\", 100*$my_n/$total}")
      echo "- 你的 commit 占总 commit 的 **$pct%** ($my_n / $total)"
      echo ""
      if [[ $(awk "BEGIN {print ($pct < 5)}") -eq 1 ]]; then
        echo "  ⚠️  **你的 git 身份在所有 commit 中占比 < 5%**"
        echo "  这意味着:"
        echo "  - 你的代码贡献可能**不在 git 里**(代码外的岗位:数据/分析/咨询/管理/设计)"
        echo "  - 应改用 **[基础层 general 证据]**(邮件/审批/沟通/位置)"
        echo "  - 不应依赖 git 证据作为主要维权依据"
        echo ""
        echo "  推荐重新跑:"
        echo '  ```bash'
        echo "  bash scripts/storage-evidence-scanner.sh  # 工作文件全盘扫描"
        echo "  bash scripts/location-worklog.sh --auto    # 位置记录"
        echo "  bash scripts/unify-summarize.sh            # 统一汇总"
        echo '  ```'
      fi
    fi
  } > "$RPT"
  echo ""
  echo "📋 账号分析报告: $RPT"
fi

echo ""
echo "💡 提示:"
echo "  - 配合 scripts/evidence-collector.sh 收集 commit 邮件"
echo "  - 配合 scripts/evidence-aggregator.sh 汇总进 case-brief"
echo "  - 推荐在 ~/.config/avle.conf 配 MY_EMAILS 过滤你自己的 commit"
echo "  - 跑 --account-report 输出完整账号分析"
