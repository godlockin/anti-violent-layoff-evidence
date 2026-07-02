#!/usr/bin/env bash
# location-worklog.sh - 记录 Work From Home / 客户现场 / 出差等不同时段的工作位置
# 适用岗位:全员通用
# 用法:
#   bash scripts/location-worklog.sh                        # 交互式
#   bash scripts/location-worklog.sh --start 2026-01-01T09:00 --end 2026-01-01T18:00 --location home --note "..."
#   bash scripts/location-worklog.sh --auto                 # 尝试自动探测(基于 WiFi SSID/SSID-history)
#   bash scripts/location-worklog.sh --print                # 显示所有记录
#   bash scripts/location-worklog.sh --ical                 # 输出 iCal
#   bash scripts/location-worklog.sh --summary 2026-01      # 月度汇总
set -euo pipefail

EVIDENCE_ROOT="${EVIDENCE_ROOT:-$HOME/evidence}"
LOG_DIR="$EVIDENCE_ROOT/location-log"
LOG_FILE="$LOG_DIR/locations.csv"
mkdir -p "$LOG_DIR"
[[ -f "$LOG_FILE" ]] || echo "start_time,end_time,location_type,location_detail,wifi_ssid,latitude,longitude,address,note,source" > "$LOG_FILE"

# 位置类型定义(用 case 替代关联数组,macOS bash 3.2 兼容)
loc_label() {
  case "$1" in
    home)       echo "家庭办公 / WFH";;
    office)     echo "公司办公室";;
    client)     echo "客户现场";;
    travel)     echo "出差";;
    coffeeshop) echo "咖啡馆";;
    coworking)  echo "联合办公";;
    commute)    echo "通勤";;
    other)      echo "其他";;
    *)          echo "";;
  esac
}
loc_is_valid() {
  case "$1" in
    home|office|client|travel|coffeeshop|coworking|commute|other) return 0;;
    *) return 1;;
  esac
}

# 默认参数
START=""
END=""
LOCATION=""
NOTE=""
SOURCE="manual"
PRINT=0
ICAL=0
SUMMARY=""
AUTO=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --start)    START="$2"; shift 2;;
    --end)      END="$2"; shift 2;;
    --location) LOCATION="$2"; shift 2;;
    --note)     NOTE="$2"; shift 2;;
    --source)   SOURCE="$2"; shift 2;;
    --auto)     AUTO=1; shift;;
    --print)    PRINT=1; shift;;
    --ical)     ICAL=1; shift;;
    --summary)  SUMMARY="$2"; shift 2;;
    --list)     echo "支持的位置类型:"; for k in home office client travel coffeeshop coworking commute other; do echo "  $k - $(loc_label "$k")"; done; exit 0;;
    -h|--help)  sed -n '2,25p' "$0"; exit 0;;
    *) echo "Unknown arg: $1" >&2; exit 1;;
  esac
done

# 自动探测
auto_detect() {
  local ssid=""
  local detail=""

  # macOS WiFi SSID
  if [[ "$(uname)" == "Darwin" ]] && command -v airport >/dev/null 2>&1; then
    ssid=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I 2>/dev/null | awk '/ SSID/{print $2}')
  fi
  if [[ -z "$ssid" ]] && [[ "$(uname)" == "Darwin" ]]; then
    ssid=$(networksetup -getairportnetwork en0 2>/dev/null | awk -F': ' '{print $2}')
  fi
  # Linux
  if [[ -z "$ssid" ]] && command -v iwgetid >/dev/null 2>&1; then
    ssid=$(iwgetid -r 2>/dev/null)
  fi

  # 时间
  local now=$(date +%Y-%m-%dT%H:%M:%S)
  local hour=$(date +%H)

  # 启发式推断位置
  local loc="other"
  local note_auto=""

  if [[ -n "$ssid" ]]; then
    case "$ssid" in
      *Company*|*OFFICE*|*CORP*|*-Guest*)
        loc="office"; note_auto="WiFi=$ssid";;
      *Home*|*Family*|*WIFI*|*TP-LINK*|*Xiaomi*|*Huawei*)
        loc="home"; note_auto="WiFi=$ssid";;
      *Starbucks*|*Costa*|*Manner*|*%Arabica*)
        loc="coffeeshop"; note_auto="WiFi=$ssid";;
      *)
        # 未知 SSID,标记为 unknown
        loc="other"; note_auto="WiFi=$ssid(未知)";;
    esac
  else
    # 无 WiFi → 通勤/外出
    if [[ $hour -ge 7 && $hour -le 9 ]]; then
      loc="commute"; note_auto="早通勤时段(无 WiFi)"
    elif [[ $hour -ge 18 && $hour -le 20 ]]; then
      loc="commute"; note_auto="晚通勤时段(无 WiFi)"
    else
      loc="other"; note_auto="无 WiFi 信号"
    fi
  fi

  START=$now
  END=$now
  LOCATION=$loc
  NOTE=$note_auto
  SOURCE="auto"

  echo "🤖 自动探测结果:"
  echo "   时间: $now"
  echo "   WiFi: ${ssid:-(无)}"
  echo "   推断位置: $loc ($(loc_label "$loc"))"
  echo "   备注: $note_auto"
}

# 单条添加
add_entry() {
  # 验证
  if [[ -z "$START" || -z "$END" || -z "$LOCATION" ]]; then
    echo "ERROR: 缺参数。可用 --auto 或 --start/--end/--location/--note" >&2
    exit 1
  fi

  # 检查 location
  if ! loc_is_valid "$LOCATION"; then
    echo "ERROR: 未知位置类型 '$LOCATION'。--list 查看支持的" >&2
    exit 1
  fi

  # WiFi 探测
  local ssid=""
  if [[ "$(uname)" == "Darwin" ]]; then
    ssid=$(networksetup -getairportnetwork en0 2>/dev/null | awk -F': ' '{print $2}')
  fi

  # CSV 转义
  safe_note=$(echo "$NOTE" | sed 's/,/;/g' | sed 's/"/""/g')
  safe_detail=$(loc_label "$LOCATION" | sed 's/,/;/g')

  echo "$START,$END,$LOCATION,$safe_detail,${ssid:-},,,,$safe_note,$SOURCE" >> "$LOG_FILE"
  echo "✅ 已记录: $START → $END [$LOCATION] $(loc_label "$LOCATION")"
}

# Print
do_print() {
  if [[ ! -s "$LOG_FILE" ]] || [[ $(wc -l < "$LOG_FILE") -le 1 ]]; then
    echo "(无记录)"
    return
  fi
  echo "=== 位置工作记录 ==="
  tail -n +2 "$LOG_FILE" | head -20
  total=$(($(wc -l < "$LOG_FILE") - 1))
  if [[ $total -gt 20 ]]; then
    echo ""
    echo "(共 $total 条,只显示前 20)"
  fi
}

# Summary
do_summary() {
  local period="$1"
  echo "=== 月度汇总: $period ==="
  echo ""
  echo "按位置类型统计(小时):"
  awk -F',' -v p="$period" 'NR>1 && $1 ~ p {
    cmd = "date -d \"" $1 "\" +%s 2>/dev/null || date -j -f \"%Y-%m-%dT%H:%M:%S\" \"" $1 "\" +%s 2>/dev/null"
    cmd | getline s
    close(cmd)
    cmd2 = "date -d \"" $2 "\" +%s 2>/dev/null || date -j -f \"%Y-%m-%dT%H:%M:%S\" \"" $2 "\" +%s 2>/dev/null"
    cmd2 | getline e
    close(cmd2)
    if (s && e && e > s) {
      hrs = (e - s) / 3600
      loc = $3
      total[loc] += hrs
    }
  } END {
    for (l in total) printf "  %-15s %6.1f 小时\n", l, total[l]
  }' "$LOG_FILE"
  echo ""
  echo "按位置类型统计(天数):"
  awk -F',' -v p="$period" 'NR>1 && $1 ~ p {count[$3]++} END {for (l in count) printf "  %-15s %d 天\n", l, count[l]}' "$LOG_FILE"
}

# iCal 输出
do_ical() {
  local ical="$LOG_DIR/locations.ics"
  {
    echo "BEGIN:VCALENDAR"
    echo "VERSION:2.0"
    echo "PRODID:-//AVLE//Location Worklog//ZH"
    echo "CALSCALE:GREGORIAN"
    echo "X-WR-CALNAME:工作位置记录"
    echo "X-WR-TIMEZONE:Asia/Shanghai"
    local i=0
    while IFS= read -r line; do
      [[ $i -eq 0 ]] && { i=$((i+1)); continue; }
      [[ -z "$line" ]] && continue
      IFS=',' read -r s e loc detail ssid lat lon addr note src <<< "$line"
      [[ -z "$s" ]] && continue
      local dt_s=$(echo "$s" | tr -d ':-' | cut -c1-15)
      local dt_e=$(echo "$e" | tr -d ':-' | cut -c1-15)
      echo "BEGIN:VEVENT"
      echo "UID:loc-$dt_s-$i@avle"
      echo "DTSTAMP:$(date -u +%Y%m%dT%H%M%SZ)"
      echo "DTSTART:${dt_s}"
      echo "DTEND:${dt_e}"
      echo "SUMMARY:[$loc] ${detail}"
      echo "DESCRIPTION:${note}"
      echo "LOCATION:${ssid:-}${addr:-}"
      echo "CATEGORIES:工作位置"
      echo "END:VEVENT"
      i=$((i+1))
    done < "$LOG_FILE"
    echo "END:VCALENDAR"
  } > "$ical"
  echo "📅 iCal: $ical"
}

# 主流程
if [[ $AUTO -eq 1 ]]; then
  auto_detect
  add_entry
elif [[ -n "$START" && -n "$LOCATION" ]]; then
  add_entry
elif [[ $PRINT -eq 1 ]]; then
  do_print
elif [[ $ICAL -eq 1 ]]; then
  do_ical
elif [[ -n "$SUMMARY" ]]; then
  do_summary "$SUMMARY"
else
  # 交互模式
  echo "=== 交互式工作位置记录 ==="
  echo "可用 --auto 自动 / --help 帮助 / --print 查看 / --ical 导出"
  echo ""
  read -rp "开始时间 (默认 now) [YYYY-MM-DDTHH:MM:SS]: " START
  START=${START:-$(date +%Y-%m-%dT%H:%M:%S)}
  read -rp "结束时间 (默认 =开始) [YYYY-MM-DDTHH:MM:SS]: " END
  END=${END:-$START}
  echo ""
  echo "位置类型:"
  for k in home office client travel coffeeshop coworking commute other; do printf "  %-12s - %s\n" "$k" "$(loc_label "$k")"; done
  echo ""
  read -rp "位置类型 [home/office/client/travel/...]: " LOCATION
  read -rp "备注: " NOTE
  add_entry
fi

echo ""
echo "💡 提示:"
echo "  - 每天 09:00 / 13:00 / 18:00 各跑一次 --auto"
echo "  - 出差前先 --auto 记录开始,回来后 --auto 记录结束"
echo "  - 配合 scripts/holiday-sync.sh 算加班费"
echo "  - 配合 scripts/evidence-aggregator.sh 汇总进 case-brief"
echo ""
echo "📂 日志: $LOG_FILE"
