#!/usr/bin/env bash
# holiday-sync.sh - 同步法定节假日 + 工作日历(可作加班费计算依据)
# Phase 1: 中国大陆(国办节假日 + 调休 + 周末)
# 用法:
#   bash scripts/holiday-sync.sh                # 同步当年
#   bash scripts/holiday-sync.sh --year 2025
#   bash scripts/holiday-sync.sh --year 2024 2025 2026
#   bash scripts/holiday-sync.sh --print        # 只显示
#   bash scripts/holiday-sync.sh --ical         # 输出 iCal
set -euo pipefail

EVIDENCE_ROOT="${EVIDENCE_ROOT:-$HOME/evidence}"
HOLIDAY_DIR="$EVIDENCE_ROOT/holidays"
YEARS=()
PRINT_ONLY=0
ICAL_ONLY=0
SOURCE="auto"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --year) YEARS+=("$2"); shift 2;;
    --print) PRINT_ONLY=1; shift;;
    --ical) ICAL_ONLY=1; shift;;
    --source) SOURCE="$2"; shift 2;;
    --output) HOLIDAY_DIR="$2"; shift 2;;
    -h|--help) sed -n '2,15p' "$0"; exit 0;;
    *) echo "Unknown arg: $1" >&2; exit 1;;
  esac
done

mkdir -p "$HOLIDAY_DIR"

# 默认当年 + 上下 1 年
if [[ ${#YEARS[@]} -eq 0 ]]; then
  cur=$(date +%Y)
  YEARS=($((cur-1)) $cur $((cur+1)))
fi

# 中国法定节假日数据(2024-2026 国办放假安排)
# 数据源:中国政府网公开发布的放假通知
# 如需更新到 2027+,运行后追加新源或 PR 到本仓库
declare -A HOLIDAYS      # date => 节假日名
declare -A ADJUSTMENTS   # date => "调休上班" 或 "调休休息"

# 2024
HOLIDAYS[2024-01-01]="元旦"
HOLIDAYS[2024-02-10]="春节"
HOLIDAYS[2024-02-11]="春节"
HOLIDAYS[2024-02-12]="春节"
HOLIDAYS[2024-02-13]="春节"
HOLIDAYS[2024-02-14]="春节"
HOLIDAYS[2024-02-15]="春节"
HOLIDAYS[2024-02-16]="春节"
HOLIDAYS[2024-02-17]="春节"
HOLIDAYS[2024-04-04]="清明节"
HOLIDAYS[2024-04-05]="清明节"
HOLIDAYS[2024-04-06]="清明节"
HOLIDAYS[2024-05-01]="劳动节"
HOLIDAYS[2024-05-02]="劳动节"
HOLIDAYS[2024-05-03]="劳动节"
HOLIDAYS[2024-05-04]="劳动节"
HOLIDAYS[2024-05-05]="劳动节"
HOLIDAYS[2024-06-10]="端午节"
HOLIDAYS[2024-09-15]="中秋节"
HOLIDAYS[2024-09-16]="中秋节"
HOLIDAYS[2024-09-17]="中秋节"
HOLIDAYS[2024-10-01]="国庆节"
HOLIDAYS[2024-10-02]="国庆节"
HOLIDAYS[2024-10-03]="国庆节"
HOLIDAYS[2024-10-04]="国庆节"
HOLIDAYS[2024-10-05]="国庆节"
HOLIDAYS[2024-10-06]="国庆节"
HOLIDAYS[2024-10-07]="国庆节"
# 2024 调休
ADJUSTMENTS[2024-02-04]="春节调休上班"
ADJUSTMENTS[2024-02-18]="春节调休上班"
ADJUSTMENTS[2024-04-07]="清明节调休上班"
ADJUSTMENTS[2024-04-28]="劳动节调休上班"
ADJUSTMENTS[2024-05-11]="劳动节调休上班"
ADJUSTMENTS[2024-09-14]="中秋节调休上班"
ADJUSTMENTS[2024-09-29]="国庆节调休上班"
ADJUSTMENTS[2024-10-12]="国庆节调休上班"

# 2025
HOLIDAYS[2025-01-01]="元旦"
HOLIDAYS[2025-01-28]="春节"
HOLIDAYS[2025-01-29]="春节"
HOLIDAYS[2025-01-30]="春节"
HOLIDAYS[2025-01-31]="春节"
HOLIDAYS[2025-02-01]="春节"
HOLIDAYS[2025-02-02]="春节"
HOLIDAYS[2025-02-03]="春节"
HOLIDAYS[2025-02-04]="春节"
HOLIDAYS[2025-04-04]="清明节"
HOLIDAYS[2025-04-05]="清明节"
HOLIDAYS[2025-04-06]="清明节"
HOLIDAYS[2025-05-01]="劳动节"
HOLIDAYS[2025-05-02]="劳动节"
HOLIDAYS[2025-05-03]="劳动节"
HOLIDAYS[2025-05-04]="劳动节"
HOLIDAYS[2025-05-05]="劳动节"
HOLIDAYS[2025-05-31]="端午节"
HOLIDAYS[2025-06-01]="端午节"
HOLIDAYS[2025-06-02]="端午节"
HOLIDAYS[2025-10-01]="国庆节"
HOLIDAYS[2025-10-02]="国庆节"
HOLIDAYS[2025-10-03]="国庆节"
HOLIDAYS[2025-10-04]="国庆节"
HOLIDAYS[2025-10-05]="国庆节"
HOLIDAYS[2025-10-06]="国庆节"
HOLIDAYS[2025-10-07]="国庆节"
HOLIDAYS[2025-10-08]="中秋节"
# 2025 调休
ADJUSTMENTS[2025-01-26]="春节调休上班"
ADJUSTMENTS[2025-02-08]="春节调休上班"
ADJUSTMENTS[2025-04-07]="清明节调休上班"
ADJUSTMENTS[2025-05-06]="劳动节调休上班"
ADJUSTMENTS[2025-09-28]="国庆节调休上班"
ADJUSTMENTS[2025-10-11]="国庆节调休上班"

# 2026(国务院 2025-11 月发布,作占位)
HOLIDAYS[2026-01-01]="元旦"
HOLIDAYS[2026-01-02]="元旦"
HOLIDAYS[2026-01-03]="元旦"
HOLIDAYS[2026-02-17]="春节"
HOLIDAYS[2026-02-18]="春节"
HOLIDAYS[2026-02-19]="春节"
HOLIDAYS[2026-02-20]="春节"
HOLIDAYS[2026-02-21]="春节"
HOLIDAYS[2026-02-22]="春节"
HOLIDAYS[2026-02-23]="春节"
HOLIDAYS[2026-04-04]="清明节"
HOLIDAYS[2026-04-05]="清明节"
HOLIDAYS[2026-04-06]="清明节"
HOLIDAYS[2026-05-01]="劳动节"
HOLIDAYS[2026-05-02]="劳动节"
HOLIDAYS[2026-05-03]="劳动节"
HOLIDAYS[2026-06-19]="端午节"
HOLIDAYS[2026-09-25]="中秋节"
HOLIDAYS[2026-09-26]="中秋节"
HOLIDAYS[2026-09-27]="中秋节"
HOLIDAYS[2026-10-01]="国庆节"
HOLIDAYS[2026-10-02]="国庆节"
HOLIDAYS[2026-10-03]="国庆节"
HOLIDAYS[2026-10-04]="国庆节"
HOLIDAYS[2026-10-05]="国庆节"
HOLIDAYS[2026-10-06]="国庆节"
HOLIDAYS[2026-10-07]="国庆节"
# 2026 调休(预测,以国办实际公布为准)
ADJUSTMENTS[2026-02-14]="春节调休上班"
ADJUSTMENTS[2026-02-28]="春节调休上班"
ADJUSTMENTS[2026-04-03]="清明节调休上班"
ADJUSTMENTS[2026-05-04]="劳动节调休上班"
ADJUSTMENTS[2026-09-24]="中秋节调休上班"
ADJUSTMENTS[2026-10-10]="国庆节调休上班"

# 写入主 manifest(holiday + 调休统一)
MANIFEST="$HOLIDAY_DIR/holidays-cn.csv"
if [[ $PRINT_ONLY -eq 0 && $ICAL_ONLY -eq 0 ]]; then
  {
    echo "date,name,jurisdiction,type,note"
    for k in $(echo "${!HOLIDAYS[@]}" | tr ' ' '\n' | sort); do
      yr=$(echo "$k" | cut -d- -f1)
      in_scope=0
      for y in "${YEARS[@]}"; do
        if [[ "$yr" == "$y" ]]; then in_scope=1; break; fi
      done
      if [[ $in_scope -eq 1 ]]; then
        # 判断是 3 倍还是 2 倍
        # 国假当天 = 300%, 调休休息 = 200%(算周末)
        type="legal"
        echo "$k,${HOLIDAYS[$k]},CN,$type,法定节假日(加班 300%)"
      fi
    done
    for k in $(echo "${!ADJUSTMENTS[@]}" | tr ' ' '\n' | sort); do
      yr=$(echo "$k" | cut -d- -f1)
      in_scope=0
      for y in "${YEARS[@]}"; do
        if [[ "$yr" == "$y" ]]; then in_scope=1; break; fi
      done
      if [[ $in_scope -eq 1 ]]; then
        adj_name=$(echo "${ADJUSTMENTS[$k]}" | sed 's/调休上班$//; s/调休休息$//')
        echo "$k,$adj_name 调休,CN,adjust,${ADJUSTMENTS[$k]}"
      fi
    done
  } > "$MANIFEST"
  echo "📅 已写入: $MANIFEST"
fi

# Print to stdout
if [[ $PRINT_ONLY -eq 1 ]] || [[ $ICAL_ONLY -eq 0 && $PRINT_ONLY -eq 0 ]]; then
  echo ""
  echo "=== 法定节假日 + 调休 (中国大陆) ==="
  for y in "${YEARS[@]}"; do
    echo ""
    echo "📅 $y 年:"
    # 节假日
    echo "   -- 法定节假日 --"
    for k in $(echo "${!HOLIDAYS[@]}" | tr ' ' '\n' | sort); do
      yr=$(echo "$k" | cut -d- -f1)
      if [[ "$yr" == "$y" ]]; then
        printf "   %s  %s (300%%)\n" "$k" "${HOLIDAYS[$k]}"
      fi
    done
    # 调休
    adj_count=$(echo "${!ADJUSTMENTS[@]}" | tr ' ' '\n' | awk -v y="$y" -F'-' '$1==y' | wc -l | tr -d ' ')
    if [[ $adj_count -gt 0 ]]; then
      echo "   -- 调休 --"
      for k in $(echo "${!ADJUSTMENTS[@]}" | tr ' ' '\n' | sort); do
        yr=$(echo "$k" | cut -d- -f1)
        if [[ "$yr" == "$y" ]]; then
          printf "   %s  %s\n" "$k" "${ADJUSTMENTS[$k]}"
        fi
      done
    fi
  done
fi

# iCal 输出
if [[ $ICAL_ONLY -eq 1 ]]; then
  ical="$HOLIDAY_DIR/holidays-cn.ics"
  {
    echo "BEGIN:VCALENDAR"
    echo "VERSION:2.0"
    echo "PRODID:-//AVLE//China Holidays//ZH"
    echo "CALSCALE:GREGORIAN"
    echo "METHOD:PUBLISH"
    echo "X-WR-CALNAME:中国法定节假日"
    echo "X-WR-TIMEZONE:Asia/Shanghai"
    for y in "${YEARS[@]}"; do
      for k in $(echo "${!HOLIDAYS[@]}" | tr ' ' '\n' | sort); do
        yr=$(echo "$k" | cut -d- -f1)
        if [[ "$yr" == "$y" ]]; then
          dt=${k//-/}
          name=${HOLIDAYS[$k]}
          echo "BEGIN:VEVENT"
          echo "UID:${dt}-cn-holiday@avle"
          echo "DTSTAMP:$(date -u +%Y%m%dT%H%M%SZ)"
          echo "DTSTART;VALUE=DATE:${dt}"
          echo "SUMMARY:${name} (法定节假日)"
          echo "CATEGORIES:法定节假日,加班费3倍"
          echo "END:VEVENT"
        fi
      done
    done
    echo "END:VCALENDAR"
  } > "$ical"
  echo ""
  echo "📅 iCal: $ical"
  echo "   导入到 macOS Calendar / Outlook / Thunderbird 即可看到全年法定节假日"
fi

# 工作日计算 helper(已包含调休工作日)
calc_workdays() {
  local year="$1" m="$2"
  python3 - <<PY 2>/dev/null || echo "(python3 不可用,跳过)"
from datetime import date, timedelta
y = $year
total_workdays = 0
holidays = set()        # 法定假日
adjustments = set()     # 调休工作日
import os, csv
if os.path.exists("$MANIFEST"):
    with open("$MANIFEST", encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            t = row.get('type', '')
            d = row.get('date', '')
            if t == 'legal':
                holidays.add(d)
            elif t == 'adjust':
                # 调休:有"上班"标记的是工作日,休息是双倍
                note = row.get('note', '')
                if '上班' in note:
                    adjustments.add(d)

d = date(y, m, 1)
while d.month == m:
    iso = d.isoformat()
    # 周末 & 法定假日 → 非工作日
    # 调休工作日 → 工作日(无论周末与否)
    if iso in adjustments:
        total_workdays += 1
    elif d.weekday() < 5 and iso not in holidays:
        total_workdays += 1
    d += timedelta(days=1)
print(f"{y}-{m:02d} 工作日(含调休): {total_workdays} 天")
PY
}

if command -v python3 >/dev/null 2>&1; then
  echo ""
  echo "=== 月度工作日统计 ==="
  for y in "${YEARS[@]}"; do
    for m in $(seq 1 12); do
      calc_workdays "$y" "$m"
    done
  done
fi

echo ""
echo "💡 用法:"
echo "  - 节假日 3 倍工资,周末 2 倍(《劳动法》§44)"
echo "  - 月度工作日 × 日工资 = 月度标准工时上限(20.83 天 × 8h = 166.64h)"
echo "  - 用这个脚本生成加班费计算依据"
echo ""
echo "⚠️  注意:"
echo "  - 2024-2026 数据硬编码在脚本内,2027+ 需更新"
echo "  - 国办每年 11-12 月公布下年放假安排,届时请更新"
echo "  - 数据源:中国政府网 www.gov.cn"
