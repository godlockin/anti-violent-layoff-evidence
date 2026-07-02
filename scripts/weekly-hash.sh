#!/usr/bin/env bash
# weekly-hash.sh - 每周五执行,30 秒完成周维护
# 用法: bash scripts/weekly-hash.sh [--dry-run]
set -euo pipefail

EVIDENCE_ROOT="${EVIDENCE_ROOT:-$HOME/evidence}"
MANIFEST="$EVIDENCE_ROOT/manifest.csv"
DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

ts=$(date +%Y-%m-%dT%H:%M:%S)
week=$(date +%G-W%V)

log() { echo "[$(date +%H:%M:%S)] $*"; }

log "=== Weekly Hash Maintenance Start: $ts (Week $week) ==="

if [[ ! -d "$EVIDENCE_ROOT" ]]; then
  log "ERROR: $EVIDENCE_ROOT 不存在"
  exit 1
fi

mkdir -p "$EVIDENCE_ROOT/timestamp"
touch "$MANIFEST"

# 1. 遍历证据目录,计算 SHA256
count=0
while IFS= read -r -d '' f; do
  hash=$(shasum -a 256 "$f" | awk '{print $1}')
  size=$(stat -f %z "$f" 2>/dev/null || stat -c %s "$f" 2>/dev/null || echo 0)
  relpath="${f#$EVIDENCE_ROOT/}"
  echo "$ts,$week,$relpath,$size,$hash" >> "$MANIFEST"
  count=$((count + 1))
done < <(find "$EVIDENCE_ROOT" -type f \( \
  -name "*.eml" -o -name "*.msg" -o -name "*.pdf" -o \
  -name "*.jpg" -o -name "*.png" -o -name "*.mp3" -o \
  -name "*.mp4" -o -name "*.json" -o -name "*.csv" -o \
  -name "*.enc" \) -print0)

log "✅ 登记 $count 条新 hash"

# 2. 申请 TSA 时间戳(可选,见 README)
if command -v curl >/dev/null 2>&1; then
  log "TIP: cd $EVIDENCE_ROOT/timestamp && tsa stamp manifest.csv" >&2
fi

# 3. rsync 到坚果云等(可选)
if [[ -d "$HOME/Nutstore" ]] && [[ "$DRY_RUN" -eq 0 ]]; then
  rsync -avz "$EVIDENCE_ROOT/manifest.csv" "$HOME/Nutstore/evidence/manifest-${week}.csv"
  log "✅ manifest 已同步到个人云"
fi

log "=== Weekly Hash Maintenance Done ==="
