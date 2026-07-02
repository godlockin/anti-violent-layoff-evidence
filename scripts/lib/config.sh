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

# 自动探测用户邮箱
# 1) 全局 git config
# 2) 最近 5 个 git 仓库的 user.email(取最频繁的)
detect_my_emails() {
  local detected=""
  local timeout_secs=5

  # 全局 git config(快速,必跑)
  local global_email
  global_email=$(git config --global user.email 2>/dev/null)
  [[ -n "$global_email" ]] && detected="$global_email"

  # 最近仓库(限制深度+超时,避免大 ~/ 拖死)
  if [[ -z "$AVLE_MY_EMAILS" ]]; then
    local repo_emails
    # macOS/Linux 通用方案:gtimeout / timeout / perl alarm
    if command -v gtimeout >/dev/null 2>&1; then
      repo_emails=$(gtimeout "$timeout_secs" find "$HOME" -maxdepth 4 -name ".git" -type d 2>/dev/null | head -10)
    elif command -v timeout >/dev/null 2>&1; then
      repo_emails=$(timeout "$timeout_secs" find "$HOME" -maxdepth 4 -name ".git" -type d 2>/dev/null | head -10)
    else
      # perl alarm 模拟超时
      repo_emails=$(perl -e '
        eval {
          local $SIG{ALRM} = sub { die "timeout\n" };
          alarm 5;
          my @lines = `find $ENV{HOME} -maxdepth 4 -name ".git" -type d 2>/dev/null | head -10`;
          alarm 0;
          print @lines;
        };
        if ($@ && $@ ne "timeout\n") { die $@; }
      ' 2>/dev/null)
    fi

    if [[ -n "$repo_emails" ]]; then
      local found
      found=$(echo "$repo_emails" | while read -r d; do
        [[ -n "$d" ]] && (cd "$(dirname "$d")" && git config user.email 2>/dev/null)
      done | grep -v "^$" | sort | uniq -c | sort -rn | head -3 | awk '{print $2}')
      detected="$detected $found"
    fi
  fi

  if [[ -n "$detected" && -z "$AVLE_MY_EMAILS" ]]; then
    AVLE_MY_EMAILS=$(echo "$detected" | tr ' ' '\n' | grep -v "^$" | sort -u | tr '\n' ' ' | sed 's/ $//')
    echo "🔍 自动探测你的 git 邮箱: $AVLE_MY_EMAILS" >&2
    echo "   如不正确,创建 ~/.config/avle.conf 覆盖" >&2
  fi
}

# 写入默认配置文件(用户首次跑时)
write_default_config() {
  if [[ ! -f "$AVLE_CONFIG_FILE" ]]; then
    mkdir -p "$AVLE_CONFIG_DIR"
    cat > "$AVLE_CONFIG_FILE" <<'EOF'
# AVLE 用户配置 / User Configuration
# 见 config/avle.conf.example 完整选项

# 你的 git 邮箱(空格分隔,自动探测失败时填这个)
MY_EMAILS=""

# 公司邮箱域名(影响 git-evidence 的"公司 vs 个人"分类)
COMPANY_DOMAIN=""
EOF
    echo "📝 已创建默认配置: $AVLE_CONFIG_FILE" >&2
    echo "   请编辑填入你的邮箱和公司域名" >&2
  fi
}

# 调用
detect_my_emails
