#!/usr/bin/env bash
# avle-launcher.sh - AVLE 引导式主入口
# 用法:
#   bash scripts/avle-launcher.sh              # 引导式(默认)
#   bash scripts/avle-launcher.sh --quick      # 快速模式(用默认 + 自动探测)
#   bash scripts/avle-launcher.sh --resume     # 跳过引导,直接跑(用已有配置)
#   bash scripts/avle-launcher.sh --config     # 只配置,不扫描
#   bash scripts/avle-launcher.sh --help
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=lib/config.sh
source "$SCRIPT_DIR/lib/config.sh"

# ===== 颜色 / Colors =====
if [[ -t 1 ]]; then
  RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'
  BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
else
  RED=''; GREEN=''; YELLOW=''; BLUE=''; CYAN=''; BOLD=''; NC=''
fi

# ===== 状态 =====
QUICK=0
RESUME=0
CONFIG_ONLY=0
DRY_RUN=0

# 工作阶段状态(供 checklist 阶段显示)
declare -a STEPS_DONE
declare -a STEPS_PENDING

# ===== 帮助 =====
show_help() {
  cat <<'EOF'
AVLE Launcher - 引导式主入口

用法:
  bash scripts/avle-launcher.sh [选项]

选项:
  (无)        完整引导(6 步,问 → 配置 → 扫描 → 报告)
  --quick     快速模式:跳过问询,用自动探测 + 默认值
  --resume    跳过引导,直接跑(用 ~/.config/avle.conf 已有配置)
  --config    只配置,问询后不扫描
  --dry-run   显示将要执行什么,不实际跑
  --help      显示这个帮助

示例:
  首次跑:    bash scripts/avle-launcher.sh
  快速复跑:  bash scripts/avle-launcher.sh --quick
  改配置:    bash scripts/avle-launcher.sh --config
  重新生成:  bash scripts/avle-launcher.sh --resume
EOF
}

# ===== 工具函数 =====
ask() {
  # ask "问题" "默认值" → 写入 ANSWER
  local prompt="$1"
  local default="${2:-}"
  local answer
  if [[ -n "$default" ]]; then
    read -rp "$(printf "${CYAN}?${NC} %s [%s]: " "$prompt" "$default")" answer
    answer="${answer:-$default}"
  else
    read -rp "$(printf "${CYAN}?${NC} %s: " "$prompt")" answer
  fi
  ANSWER="$answer"
}

ask_yn() {
  # ask_yn "问题" "默认(y/n)" → 写入 ANSWER_YN (1/0)
  local prompt="$1"
  local default="$2"
  local yn_label
  case "$default" in
    y|Y) yn_label="Y/n" ;;
    n|N) yn_label="y/N" ;;
    *)   yn_label="y/n" ;;
  esac
  local answer
  read -rp "$(printf "${CYAN}?${NC} %s [%s]: " "$prompt" "$yn_label")" answer
  answer="${answer:-$default}"
  case "$answer" in
    y|Y|yes|YES) ANSWER_YN=1 ;;
    *)           ANSWER_YN=0 ;;
  esac
}

# 显示分隔线
hr() {
  printf "${BLUE}%s${NC}\n" "────────────────────────────────────────────────────────────────"
}

# 进度条
progress() {
  local cur=$1 total=$2 label="$3"
  local pct=$(( cur * 100 / total ))
  local filled=$(( pct / 5 ))
  local empty=$(( 20 - filled ))
  local bar
  bar=$(printf '█%.0s' $(seq 1 $filled 2>/dev/null) 2>/dev/null || echo "")
  bar="$bar$(printf '░%.0s' $(seq 1 $empty 2>/dev/null) 2>/dev/null || echo "")"
  printf "\r${CYAN}[%s]${NC} %3d%% %s" "$bar" "$pct" "$label"
  [[ $cur -eq $total ]] && echo ""
}

# 写入 avle.conf
save_config() {
  mkdir -p "$(dirname "$AVLE_CONFIG_FILE")"
  cat > "$AVLE_CONFIG_FILE" <<EOF
# AVLE 用户配置 / User Configuration
# 由 avle-launcher.sh 自动生成,可手动修改

# 你的 git 邮箱(空格分隔)
MY_EMAILS="$AVLE_MY_EMAILS"

# 公司邮箱域名(用于 git-evidence 识别公司账号)
COMPANY_DOMAIN="$AVLE_COMPANY_DOMAIN"

# 证据根目录
EVIDENCE_ROOT="$AVLE_EVIDENCE_ROOT"

# 跳过扫描的目录
EXCLUDE_DIRS="$AVLE_EXCLUDE_DIRS"

# 国家/地区代码
JURISDICTION="$AVLE_JURISDICTION"

# 公司 WiFi SSID
COMPANY_WIFI_SSID="$AVLE_COMPANY_WIFI_SSID"

# 家庭 WiFi SSID
HOME_WIFI_SSID="$AVLE_HOME_WIFI_SSID"

# 可信家人
TRUSTED_NAME="$AVLE_TRUSTED_NAME"
TRUSTED_PHONE="$AVLE_TRUSTED_PHONE"

# 律师
LAWYER_NAME="$AVLE_LAWYER_NAME"
LAWYER_PHONE="$AVLE_LAWYER_PHONE"

# 启用的模块
ENABLE_GIT_SCAN=$ENABLE_GIT_SCAN
ENABLE_STORAGE_SCAN=$ENABLE_STORAGE_SCAN
ENABLE_HOLIDAY_SYNC=$ENABLE_HOLIDAY_SYNC
ENABLE_LOCATION_INIT=$ENABLE_LOCATION_INIT
ENABLE_SCANNER=$ENABLE_SCANNER
ENABLE_AGGREGATOR=$ENABLE_AGGREGATOR
EOF
  echo -e "${GREEN}✓${NC} 配置已保存: $AVLE_CONFIG_FILE"
}

# 解析参数
while [[ $# -gt 0 ]]; do
  case "$1" in
    --quick)   QUICK=1; shift;;
    --resume)  RESUME=1; shift;;
    --config)  CONFIG_ONLY=1; shift;;
    --dry-run) DRY_RUN=1; shift;;
    -h|--help) show_help; exit 0;;
    *) echo "Unknown arg: $1" >&2; show_help; exit 1;;
  esac
done

# ===========================
# 欢迎语
# ===========================
clear 2>/dev/null || true
hr
echo -e "${BOLD}🛡️  AVLE - 反暴力裁员证据链${NC}"
hr
echo ""
echo "防御性工具,帮助你在被暴力裁员、锁号、清退时"
echo "仍能证明你的工作内容、时间、强度、成果,并据此索取应得赔偿。"
echo ""
echo -e "${YELLOW}⚖️  法律声明${NC}"
echo "本工具仅整理证据保留方法,不构成法律意见,不教唆对抗、伪造、报复"
echo "或侵犯商业秘密。具体案件请咨询执业律师。"
echo ""
hr
echo ""

# ===========================
# Step 1: 配置邮箱
# ===========================
echo -e "${BOLD}${BLUE}Step 1/6 — 你的 git 邮箱${NC}"
echo ""
echo "用于:git-evidence 识别'你自己的 commit'(过滤掉 open source 上游贡献者)"
echo ""

if [[ $QUICK -eq 1 ]] || [[ $RESUME -eq 1 ]]; then
  if [[ -z "$AVLE_MY_EMAILS" ]]; then
    echo -e "${YELLOW}⚠️  未配置 MY_EMAILS,使用全局 git config 探测${NC}"
    detect_my_emails
  else
    echo -e "${GREEN}✓${NC} 使用已有配置: $AVLE_MY_EMAILS"
  fi
else
  if [[ -n "$AVLE_MY_EMAILS" ]]; then
    echo -e "已配置: ${GREEN}$AVLE_MY_EMAILS${NC}"
    ask_yn "用这个?" "y"
    if [[ $ANSWER_YN -eq 0 ]]; then
      AVLE_MY_EMAILS=""
    fi
  fi

  if [[ -z "$AVLE_MY_EMAILS" ]]; then
    detect_my_emails
    echo ""
    ask "你的 git 邮箱(空格分隔,回车用探测结果)" "$AVLE_MY_EMAILS"
    AVLE_MY_EMAILS="$ANSWER"
  fi
fi
echo ""

# ===========================
# Step 2: 配置公司域名
# ===========================
echo -e "${BOLD}${BLUE}Step 2/6 — 你的公司域名${NC}"
echo ""
echo "用于:git-evidence 把公司邮箱的 commit 标为'COMPANY'(可能涉及公司项目)"
echo "示例:acme.com / <company-domain> / bytedance.com"
echo ""

if [[ $QUICK -eq 1 ]] || [[ $RESUME -eq 1 ]]; then
  if [[ -z "$AVLE_COMPANY_DOMAIN" ]]; then
    echo -e "${YELLOW}⚠️  未配置,自动从邮箱推断${NC}"
    if [[ -n "$AVLE_MY_EMAILS" ]]; then
      first_email=$(echo "$AVLE_MY_EMAILS" | awk '{print $1}')
      AVLE_COMPANY_DOMAIN=$(echo "$first_email" | awk -F@ '{print $2}')
      echo -e "  推断: ${GREEN}$AVLE_COMPANY_DOMAIN${NC}"
    fi
  else
    echo -e "${GREEN}✓${NC} 使用: $AVLE_COMPANY_DOMAIN"
  fi
else
  # 自动从邮箱推断
  auto_domain=""
  if [[ -n "$AVLE_MY_EMAILS" ]]; then
    first_email=$(echo "$AVLE_MY_EMAILS" | awk '{print $1}')
    auto_domain=$(echo "$first_email" | awk -F@ '{print $2}')
  fi

  ask "公司域名" "${AVLE_COMPANY_DOMAIN:-$auto_domain}"
  AVLE_COMPANY_DOMAIN="$ANSWER"
fi
echo ""

# ===========================
# Step 3: 配置扫描目录
# ===========================
echo -e "${BOLD}${BLUE}Step 3/6 — 扫描目录${NC}"
echo ""
echo "默认扫描 ~/Documents ~/Desktop ~/Downloads ~/Pictures ~/Movies ~/Music + 16 个网盘"
echo "(OneDrive / iCloud / 坚果云 / 百度网盘 / 腾讯微云 / 阿里云盘 / 天翼云盘 / WPS / 移动 / 115 等)"
echo "耗时通常 1-5 分钟,取决于文件数量"
echo ""

if [[ $QUICK -eq 1 ]] || [[ $RESUME -eq 1 ]]; then
  echo -e "${GREEN}✓${NC} 使用默认根: $HOME"
else
  ask "扫描根目录(回车默认)" "$HOME"
  SCAN_ROOT="$ANSWER"
fi
echo ""

# ===========================
# Step 4: 功能模块开关
# ===========================
echo -e "${BOLD}${BLUE}Step 4/6 — 启用哪些模块?${NC}"
echo ""
echo "默认全部开启,按 Y 接受,n 关闭"

# 默认值
: "${ENABLE_GIT_SCAN:=1}"
: "${ENABLE_STORAGE_SCAN:=1}"
: "${ENABLE_HOLIDAY_SYNC:=1}"
: "${ENABLE_LOCATION_INIT:=1}"
: "${ENABLE_SCANNER:=1}"
: "${ENABLE_AGGREGATOR:=1}"

if [[ $QUICK -eq 1 ]] || [[ $RESUME -eq 1 ]]; then
  echo "  全部模块: 启用"
else
  ask_yn "🔧 git-evidence-scanner (程序员 commit 遍历)" "y"; ENABLE_GIT_SCAN=$ANSWER_YN
  ask_yn "📁 storage-evidence-scanner (多存储工作文件扫描)" "y"; ENABLE_STORAGE_SCAN=$ANSWER_YN
  ask_yn "📅 holiday-sync (法定节假日 2024-2026 + 调休)" "y"; ENABLE_HOLIDAY_SYNC=$ANSWER_YN
  ask_yn "📍 location-worklog (位置记录初始化 + 一次 --auto)" "y"; ENABLE_LOCATION_INIT=$ANSWER_YN
  ask_yn "🔍 evidence-scanner (本地痕迹扫描)" "y"; ENABLE_SCANNER=$ANSWER_YN
  ask_yn "📊 unify-summarize (统一汇总 → case-brief.md)" "y"; ENABLE_AGGREGATOR=$ANSWER_YN
fi
echo ""

# 保存配置
if [[ $QUICK -eq 0 ]] && [[ $RESUME -eq 0 ]]; then
  if [[ $CONFIG_ONLY -eq 1 ]]; then
    # --config 模式:强制保存
    save_config
    echo ""
    echo -e "${GREEN}✓${NC} 配置完成(--config 模式,不扫描)"
    exit 0
  else
    ask_yn "💾 保存配置到 ~/.config/avle.conf?" "y"
    if [[ $ANSWER_YN -eq 1 ]]; then
      save_config
    fi
    echo ""
  fi
fi

# ===========================
# Step 5: 确认 + 开始
# ===========================
hr
echo -e "${BOLD}📋 即将执行:${NC}"
[[ $ENABLE_GIT_SCAN -eq 1 ]] && echo "  ✓ git-evidence-scanner --account-report"
[[ $ENABLE_STORAGE_SCAN -eq 1 ]] && echo "  ✓ storage-evidence-scanner"
[[ $ENABLE_HOLIDAY_SYNC -eq 1 ]] && echo "  ✓ holiday-sync"
[[ $ENABLE_LOCATION_INIT -eq 1 ]] && echo "  ✓ location-worklog --auto"
[[ $ENABLE_SCANNER -eq 1 ]] && echo "  ✓ evidence-scanner"
[[ $ENABLE_AGGREGATOR -eq 1 ]] && echo "  ✓ unify-summarize"
hr
echo ""

if [[ $QUICK -eq 0 ]] && [[ $RESUME -eq 0 ]]; then
  ask_yn "🚀 开始执行?" "y"
  if [[ $ANSWER_YN -eq 0 ]]; then
    echo "已取消"
    exit 0
  fi
fi

if [[ $DRY_RUN -eq 1 ]]; then
  echo -e "${YELLOW}[DRY-RUN]${NC} 不实际执行"
  exit 0
fi

mkdir -p "$AVLE_EVIDENCE_ROOT"

# ===========================
# Step 6: 执行 + 进度 + checklist
# ===========================
hr
echo -e "${BOLD}Step 6/6 — 执行扫描${NC}"
hr
echo ""

cd "$ROOT_DIR"

total_steps=0
[[ $ENABLE_GIT_SCAN -eq 1 ]] && total_steps=$((total_steps+1))
[[ $ENABLE_STORAGE_SCAN -eq 1 ]] && total_steps=$((total_steps+1))
[[ $ENABLE_HOLIDAY_SYNC -eq 1 ]] && total_steps=$((total_steps+1))
[[ $ENABLE_LOCATION_INIT -eq 1 ]] && total_steps=$((total_steps+1))
[[ $ENABLE_SCANNER -eq 1 ]] && total_steps=$((total_steps+1))
[[ $ENABLE_AGGREGATOR -eq 1 ]] && total_steps=$((total_steps+1))

cur=0

run_step() {
  local name="$1"
  local desc="$2"
  shift 2
  cur=$((cur+1))
  echo ""
  progress "$cur" "$total_steps" "$desc"
  echo -e "\n${CYAN}→${NC} $name"
  echo ""

  if "$@" >/dev/null 2>&1; then
    STEPS_DONE+=("$desc")
    echo -e "${GREEN}✓${NC} $desc 完成"
  else
    local rc=$?
    STEPS_PENDING+=("$desc")
    echo -e "${RED}✗${NC} $desc 失败(exit=$rc)"
  fi
}

[[ $ENABLE_HOLIDAY_SYNC -eq 1 ]] && run_step "holiday-sync" "📅 节假日同步" bash scripts/holiday-sync.sh
[[ $ENABLE_LOCATION_INIT -eq 1 ]] && run_step "location-init" "📍 位置记录初始化" bash scripts/location-worklog.sh --auto
[[ $ENABLE_STORAGE_SCAN -eq 1 ]] && run_step "storage-scan" "📁 多存储工作文件扫描" bash scripts/storage-evidence-scanner.sh
[[ $ENABLE_GIT_SCAN -eq 1 ]] && run_step "git-scan" "🔧 git 账号分析" bash scripts/git-evidence-scanner.sh --account-report
[[ $ENABLE_SCANNER -eq 1 ]] && run_step "scanner" "🔍 本地痕迹扫描" bash scripts/evidence-scanner.sh
[[ $ENABLE_AGGREGATOR -eq 1 ]] && run_step "aggregator" "📊 统一汇总" bash scripts/unify-summarize.sh

# ===========================
# 输出 checklist
# ===========================
hr
echo ""
echo -e "${BOLD}${GREEN}✅ 扫描完成 / Scan Complete${NC}"
hr
echo ""

# 统计
if [[ -f "$AVLE_EVIDENCE_ROOT/manifest.csv" ]]; then
  hash_n=$(tail -n +2 "$AVLE_EVIDENCE_ROOT/manifest.csv" 2>/dev/null | wc -l | tr -d ' ')
  echo -e "  📦 manifest: ${GREEN}$hash_n${NC} 条"
fi
if compgen -G "$AVLE_EVIDENCE_ROOT/storage-evidence/*.csv" >/dev/null; then
  files_n=$(find "$AVLE_EVIDENCE_ROOT" -type f -name "*.pdf" -o -name "*.docx" -o -name "*.xlsx" -o -name "*.png" -o -name "*.jpg" 2>/dev/null | wc -l | tr -d ' ')
  echo -e "  📁 工作文件扫描记录: ${GREEN}$(ls "$AVLE_EVIDENCE_ROOT/storage-evidence/"*.csv 2>/dev/null | wc -l | tr -d ' ')${NC} 个 CSV"
fi
if compgen -G "$AVLE_EVIDENCE_ROOT/git-evidence/*.csv" >/dev/null; then
  echo -e "  🔧 git commit 记录: ${GREEN}$(ls "$AVLE_EVIDENCE_ROOT/git-evidence/"*.csv 2>/dev/null | wc -l | tr -d ' ')${NC} 个 CSV"
fi
if [[ -f "$AVLE_EVIDENCE_ROOT/holidays/holidays-cn.csv" ]]; then
  h_n=$(awk -F',' 'NR>1 && $4=="legal"' "$AVLE_EVIDENCE_ROOT/holidays/holidays-cn.csv" | wc -l | tr -d ' ')
  echo -e "  📅 法定节假日: ${GREEN}$h_n${NC} 天"
fi
if [[ -f "$AVLE_EVIDENCE_ROOT/case-brief.md" ]]; then
  cb_lines=$(wc -l < "$AVLE_EVIDENCE_ROOT/case-brief.md" | tr -d ' ')
  echo -e "  📊 case-brief.md: ${GREEN}$cb_lines${NC} 行"
fi
echo ""
echo -e "  📂 证据根目录: ${BOLD}$AVLE_EVIDENCE_ROOT${NC}"
echo ""

# Checklist
hr
echo -e "${BOLD}📋 接下来你可以 / Next Steps Checklist${NC}"
hr
echo ""

if [[ ${#STEPS_DONE[@]} -gt 0 ]]; then
  echo -e "${GREEN}✅ 已完成:${NC}"
  for s in "${STEPS_DONE[@]}"; do
    echo "  ✓ $s"
  done
  echo ""
fi

if [[ ${#STEPS_PENDING[@]} -gt 0 ]]; then
  echo -e "${RED}❌ 待补 / 部分失败:${NC}"
  for s in "${STEPS_PENDING[@]}"; do
    echo "  ✗ $s"
  done
  echo ""
fi

echo -e "${BOLD}🔧 你现在可以做的:${NC}"
cat <<EOF
  □ ${BOLD}查看证据汇总${NC}
      cat $AVLE_EVIDENCE_ROOT/case-brief.md
      cat $AVLE_EVIDENCE_ROOT/git-evidence/account-report-*.md

  □ ${BOLD}配置周维护 cron${NC}
      echo "0 18 * * 5 bash $ROOT_DIR/scripts/weekly-hash.sh" | crontab -

  □ ${BOLD}加密打包(给律师)${NC}
      bash $ROOT_DIR/scripts/evidence-collector.sh --apply
      # 或:bash $ROOT_DIR/scripts/unify-summarize.sh --package

  □ ${BOLD}补强证据(基础层 general)${NC}
      - 每月:个税 APP / 社保 APP / 公积金 APP 截图
      - 每月:银行工资流水导出
      - 每周:个税申报截图
      - 每天:bash scripts/location-worklog.sh --auto (3 次)

  □ ${BOLD}复跑(用新数据更新)${NC}
      bash $ROOT_DIR/scripts/avle-launcher.sh --quick

  □ ${BOLD}改配置${NC}
      bash $ROOT_DIR/scripts/avle-launcher.sh --config
EOF
echo ""

# 律师面谈前 checklist
if [[ -f "$AVLE_EVIDENCE_ROOT/case-brief.md" ]]; then
  echo -e "${BOLD}⚖️  律师面谈前 checklist:${NC}"
  cat <<'EOF'
  □ case-brief.md 已审阅
  □ 关键证据已公证(权利卫士/区块链/线下公证处)
  □ 已打印纸质备份 1 份
  □ 已拷贝 U 盘 + 信任家人物业
  □ 已准备身份证 + 工资条 + 合同副本
  □ 已咨询法律援助中心(免费,12348)
  □ 1 年仲裁时效警告:剩余 ____ 天
EOF
fi

echo ""
hr
echo -e "${BOLD}💡 提示${NC}"
echo "  复跑: bash $ROOT_DIR/scripts/avle-launcher.sh --quick"
echo "  改配置: bash $ROOT_DIR/scripts/avle-launcher.sh --config"
echo "  应急(60秒): bash $ROOT_DIR/scripts/incident-tools.sh"
echo "  帮助: bash $ROOT_DIR/scripts/avle-launcher.sh --help"
hr
echo ""
