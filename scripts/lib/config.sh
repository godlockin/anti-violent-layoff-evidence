#!/usr/bin/env bash
# scripts/lib/config.sh - 加载 ~/.config/avle.conf + 自动探测
# 用法: source scripts/lib/config.sh

AVLE_CONFIG_FILE="${AVLE_CONFIG_FILE:-$HOME/.config/avle.conf}"
AVLE_CONFIG_DIR="${AVLE_CONFIG_DIR:-$HOME/.config}"

# 默认值
AVLE_MY_EMAILS=""
AVLE_COMPANY_DOMAIN=""
AVLE_EVIDENCE_ROOT="${EVIDENCE_ROOT:-$HOME/evidence}"
AVLE_EXCLUDE_DIRS=""
AVLE_JURISDICTION="CN"
AVLE_COMPANY_WIFI_SSID=""
AVLE_HOME_WIFI_SSID=""
AVLE_TRUSTED_NAME=""
AVLE_TRUSTED_PHONE=""
AVLE_LAWYER_NAME=""
AVLE_LAWYER_PHONE=""
AVLE_USE_RUST=0
AVLE_WEEKLY_HASH=1

# 加载用户配置
if [[ -f "$AVLE_CONFIG_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$AVLE_CONFIG_FILE"
fi

# 导出
export AVLE_MY_EMAILS
export AVLE_COMPANY_DOMAIN
export AVLE_EVIDENCE_ROOT
export AVLE_EXCLUDE_DIRS
export AVLE_JURISDICTION
export AVLE_COMPANY_WIFI_SSID
export AVLE_HOME_WIFI_SSID
export AVLE_TRUSTED_NAME
export AVLE_TRUSTED_PHONE
export AVLE_LAWYER_NAME
export AVLE_LAWYER_PHONE
export AVLE_USE_RUST
export AVLE_WEEKLY_HASH

# 邮箱是否可疑(自动排除)
_is_personal_email() {
  local email="$1"
  [[ "$email" =~ @noreply\. ]] && return 1
  [[ "$email" =~ noreply@ ]] && return 1
  [[ "$email" =~ @localhost$ ]] && return 1
  [[ "$email" =~ @127\.0\.0\.1 ]] && return 1
  [[ "$email" =~ @192\.168\. ]] && return 1
  [[ "$email" =~ @10\.0\.0\. ]] && return 1
  return 0
}

# 收集某个 .git 目录的用户邮箱(优先 git config,fallback git log 历史)
_collect_repo_email() {
  local d="$1"
  local out="$2"
  local email
  email=$(cd "$d" && git config user.email 2>/dev/null)
  if [[ -n "$email" ]]; then
    echo "$email" >> "$out"
  fi
  # 兜底:从 git log 历史提取(可能发现已弃用的公司邮箱)
  (cd "$d" && git --no-pager log --all --pretty=tformat:'%ae%n%ce' 2>/dev/null | head -100) >> "$out" 2>/dev/null || true
}

# 自动探测用户邮箱(改进版 v1.2.5)
#
# 多源探测:
# 1) 全局 git config
# 2) ~/*.gitconfig 文件
# 3) ~/ 下所有 .git 目录的 user.email (深度 8 覆盖 JetBrains)
# 4) ~/ 下所有 .git 目录的 git log 历史 author/committer email
# 5) 显式 JetBrains/VSCode 位置(可能漏掉)
#
# 输出 Top 5 候选邮箱(按使用频率),过滤 noreply/localhost/IP
detect_my_emails() {
  local detected=""
  local timeout_secs=15
  local candidates_file
  candidates_file=$(mktemp -t avle_emails.XXXXXX)
  trap 'rm -f "$candidates_file"' RETURN

  # === Source 1: 全局 git config ===
  local global_email
  global_email=$(git config --global user.email 2>/dev/null)
  [[ -n "$global_email" ]] && echo "$global_email" >> "$candidates_file"

  # === Source 2: ~/.gitconfig ===
  if [[ -f "$HOME/.gitconfig" ]]; then
    local cfg_email
    cfg_email=$(git config --file "$HOME/.gitconfig" user.email 2>/dev/null)
    [[ -n "$cfg_email" ]] && echo "$cfg_email" >> "$candidates_file"
  fi

  # === Source 3+4: 找所有 .git 目录,提取 user.email + git log 历史 ===
  local repo_dirs
  repo_dirs=$(mktemp -t avle_repos.XXXXXX)
  if command -v gtimeout >/dev/null 2>&1; then
    gtimeout "$timeout_secs" find "$HOME" -maxdepth 8 -name ".git" -type d 2>/dev/null | head -50 > "$repo_dirs" 2>/dev/null || true
  elif command -v timeout >/dev/null 2>&1; then
    timeout "$timeout_secs" find "$HOME" -maxdepth 8 -name ".git" -type d 2>/dev/null | head -50 > "$repo_dirs" 2>/dev/null || true
  else
    find "$HOME" -maxdepth 8 -name ".git" -type d 2>/dev/null | head -50 > "$repo_dirs" 2>/dev/null || true
  fi

  if [[ -s "$repo_dirs" ]]; then
    while IFS= read -r d; do
      [[ -z "$d" ]] && continue
      _collect_repo_email "$d" "$candidates_file"
    done < "$repo_dirs"
  fi
  rm -f "$repo_dirs"

  # === 统计 + 排序 ===
  if [[ -s "$candidates_file" ]]; then
    local ranked
    ranked=$(sort "$candidates_file" | uniq -c | sort -rn | head -5 | awk '{$1=""; print $0}' | sed 's/^ //' | grep -v "^$")

    if [[ -n "$ranked" ]]; then
      # 智能筛选:排除 noreply / localhost / IP / 罕见邮箱
      local filtered=""
      while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        local cnt
        cnt=$(grep -cF "$line" "$candidates_file" 2>/dev/null || echo 0)
        if _is_personal_email "$line" && [[ $cnt -gt 2 ]]; then
          filtered+="$line"$'\n'
        fi
      done <<< "$ranked"

      # 输出(无论是否设置 AVLE_MY_EMAILS,都打印发现的邮箱)
      echo "🔍 自动探测到你的 git 邮箱(按使用频率排序):" >&2
      while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        local cnt
        cnt=$(grep -cF "$line" "$candidates_file" 2>/dev/null || echo 0)
        echo "   $line (出现 $cnt 次)" >&2
      done <<< "$ranked"
      echo "" >&2
      echo "   已过滤 noreply / localhost / IP / 罕见邮箱" >&2
      echo "   ✏️  写入 ~/.config/avle.conf 可覆盖" >&2
      echo "      MY_EMAILS=\"<your-personal-email> <another>\"" >&2

      # 默认取过滤后所有给 MY_EMAILS(用户可手动改 ~/.config/avle.conf)
      if [[ -z "$AVLE_MY_EMAILS" ]]; then
        if [[ -n "$filtered" ]]; then
          AVLE_MY_EMAILS=$(echo "$filtered" | tr '\n' ' ' | sed 's/ $//')
        else
          AVLE_MY_EMAILS=$(echo "$ranked" | head -1)
        fi
      fi
    fi
  fi
}

# 写入默认配置文件(用户首次跑时)
write_default_config() {
  if [[ ! -f "$AVLE_CONFIG_FILE" ]]; then
    mkdir -p "$AVLE_CONFIG_DIR"
    cat > "$AVLE_CONFIG_FILE" <<EOF2
# AVLE 用户配置 / User Configuration
# 见 config/avle.conf.example 完整选项

# 你的 git 邮箱(空格分隔,自动探测失败时填这个)
MY_EMAILS=""

# 公司邮箱域名(影响 git-evidence 的"公司 vs 个人"分类)
COMPANY_DOMAIN=""
EOF2
    echo "📝 已创建默认配置: $AVLE_CONFIG_FILE" >&2
    echo "   请编辑填入你的邮箱和公司域名" >&2
  fi
}

# 调用
detect_my_emails
