#!/usr/bin/env bash
# storage-evidence-scanner.sh - 扫描多个存储(本地磁盘 + OneDrive + iCloud + 坚果云 + 百度网盘 + Google Drive)
# 记录工作文件路径 + 大小 + 修改时间 + 可能作者,作为工作痕迹证据
# 适用岗位:全员通用 (general)
# 用法:
#   bash scripts/storage-evidence-scanner.sh                  # 默认扫 ~/ 和常见云盘挂载点
#   bash scripts/storage-evidence-scanner.sh --paths ~/extra
#   bash scripts/storage-evidence-scanner.sh --json
#   bash scripts/storage-evidence-scanner.sh --since 30       # 最近 30 天修改
set -euo pipefail

EVIDENCE_ROOT="${EVIDENCE_ROOT:-$HOME/evidence}"
OUTDIR="$EVIDENCE_ROOT/storage-evidence"
DAYS_BACK=0
JSON=0
EXTRA_PATHS=()
NO_CLOUD=0

# 默认扫描根
declare -a DEFAULT_PATHS=(
  # === 本地 ===
  "$HOME/Documents"
  "$HOME/Desktop"
  "$HOME/Downloads"
  "$HOME/Pictures"
  "$HOME/Movies"
  "$HOME/Music"
  "$HOME/Projects"
  "$HOME/Code"
  "$HOME/Work"
  "$HOME/workspace"
  # === 海外云盘 ===
  "$HOME/OneDrive"                    # OneDrive 个人版
  "$HOME/OneDrive - Personal"
  "$HOME/iCloud Drive"                # iCloud Drive (桌面)
  "$HOME/Google Drive"                # Google Drive 个人
  "$HOME/Dropbox"                     # Dropbox
  "$HOME/MEGA"                        # Mega.nz
  "$HOME/pCloud Drive"
  "$HOME/Box"
  "$HOME/Sync"
  "$HOME/ownCloud"
  "$HOME/nextcloud"
  # === 国内云盘 ===
  "$HOME/坚果云"                       # 坚果云
  "$HOME/Nutstore"
  "$HOME/百度网盘"                     # 百度网盘
  "$HOME/BaiduNetdisk"
  "$HOME/百度云同步盘"
  "$HOME/Weiyun"                      # 腾讯微云
  "$HOME/微云"
  "$HOME/Documents/Weiyun"
  "$HOME/阿里云盘"                     # 阿里云盘
  "$HOME/AliyunDrive"
  "$HOME/aliyun-drive"
  "$HOME/天翼云盘"                     # 天翼云盘(电信)
  "$HOME/CTYun"
  "$HOME/WPS Cloud"                   # WPS 云盘
  "$HOME/WPSDrive"
  "$HOME/WPS网盘"
  "$HOME/MobileCloud"                 # 移动云盘
  "$HOME/移动云盘"
  "$HOME/115网盘"                      # 115 网盘
  "$HOME/115Cloud"
  # === iCloud 系统路径 ===
  "$HOME/Library/Mobile Documents/com~apple~CloudDocs"
  # === OneDrive 商业版(通配,展开) ===
)

while [[ $# -gt 0 ]]; do
  case "$1" in
    --paths)   shift; while [[ $# -gt 0 && "$1" != --* ]]; do EXTRA_PATHS+=("$1"); shift; done;;
    --since)   DAYS_BACK="$2"; shift 2;;
    --json)    JSON=1; shift;;
    --no-cloud) NO_CLOUD=1; shift;;
    --output)  OUTDIR="$2"; shift 2;;
    -h|--help) sed -n '2,20p' "$0"; exit 0;;
    *) echo "Unknown arg: $1" >&2; exit 1;;
  esac
done

mkdir -p "$OUTDIR"
stamp=$(date +%Y%m%d-%H%M%S)

# 构建扫描根:默认 + 附加
scan_paths=()
for p in "${DEFAULT_PATHS[@]}"; do
  [[ -d "$p" ]] && scan_paths+=("$p")
done
for p in "${EXTRA_PATHS[@]}"; do
  [[ -d "$p" ]] && scan_paths+=("$p")
done

# === OneDrive 商业版通配展开 ===
# 公司名作为后缀,如 "OneDrive - Acme Corp"
if [[ -d "$HOME" ]]; then
  while IFS= read -r od; do
    scan_paths+=("$od")
  done < <(find "$HOME" -maxdepth 2 -type d -name "OneDrive - *" 2>/dev/null)
fi

# === macOS 挂载点(/Volumes) ===
# 包括移动硬盘 / U 盘 / NAS / 时间机器
# 跳过系统卷(Macintosh HD / Preboot / Recovery)
if [[ -d "/Volumes" ]] && [[ "$(uname)" == "Darwin" ]]; then
  while IFS= read -r mp; do
    name=$(basename "$mp")
    # 跳过系统卷
    case "$name" in
      "Macintosh HD"|"Preboot"|"Recovery"|"VM"|"Data")
        continue
        ;;
    esac
    # 跳过本机启动盘(用 mount 查)
    if ! mount | grep -q "on $mp "; then
      scan_paths+=("$mp")
    fi
  done < <(find /Volumes -maxdepth 1 -mindepth 1 -type d 2>/dev/null)
fi

# === Linux/macOS 外接设备 ===
if [[ -d "/media/$USER" ]]; then
  while IFS= read -r mp; do
    scan_paths+=("$mp")
  done < <(find "/media/$USER" -maxdepth 2 -type d 2>/dev/null)
fi
if [[ -d "/mnt" ]]; then
  while IFS= read -r mp; do
    scan_paths+=("$mp")
  done < <(find /mnt -maxdepth 2 -type d 2>/dev/null)
fi

# 去重
declare -A seen
final_paths=()
for p in "${scan_paths[@]}"; do
  rp=$(cd "$p" 2>/dev/null && pwd -P || echo "$p")
  if [[ -z "${seen[$rp]:-}" ]]; then
    seen[$rp]=1
    final_paths+=("$rp")
  fi
done

if [[ ${#final_paths[@]} -eq 0 ]]; then
  echo "⚠️  未发现可扫描目录。检查 --paths 或安装云盘客户端。"
  exit 0
fi

echo "🗂️  扫描 ${#final_paths[@]} 个存储根目录"
for p in "${final_paths[@]}"; do
  echo "  → $p"
done

# 工作文件扩展名(广义)
declare -a WORK_EXTS=(
  # Office
  "doc" "docx" "docm" "dot" "dotx"
  "xls" "xlsx" "xlsm" "csv" "xlsb" "ods"
  "ppt" "pptx" "pptm" "ppsx" "odp"
  "pdf"
  "wps" "rtf" "odt" "pages" "numbers" "key"
  # 邮件
  "eml" "msg" "mbox" "pst" "ost"
  # 文本
  "txt" "md" "markdown" "rst"
  "log"
  "json" "yaml" "yml" "toml" "ini" "conf" "cfg" "properties"
  "xml" "html" "htm"
  # 代码(非 git)
  "py" "js" "ts" "tsx" "jsx" "java" "kt" "go" "rs" "c" "cpp" "h" "hpp" "cs" "rb" "php" "sh" "bash" "zsh" "sql" "r" "scala" "lua" "swift" "m" "mm" "dart"
  # 数据
  "db" "sqlite" "sqlite3" "mdb" "accdb" "dbf"
  # 设计
  "psd" "ai" "sketch" "fig" "xd" "indd"
  # 压缩
  "zip" "rar" "7z" "tar" "gz" "bz2" "xz"
  # 凭证类
  "ics" "vcf" "vcs"
  # 截图
  "psd" "png" "jpg" "jpeg" "gif" "bmp" "tiff" "webp" "heic"
)

# 排除目录
declare -a EXCLUDE_DIRS=(
  ".git" "node_modules" "target" "build" "dist" ".next" ".nuxt" ".cache"
  "__pycache__" ".pytest_cache" ".mypy_cache" ".tox" ".venv" "venv"
  ".idea" ".vscode" "*.swp" "*.swo" ".DS_Store"
  ".Trash" "$RECYCLE.BIN"
)

# 拼 find exclude
exclude_args=()
for d in "${EXCLUDE_DIRS[@]}"; do
  exclude_args+=(-name "$d" -prune -o)
done

# 时间过滤
find_time_args=()
if [[ "$DAYS_BACK" -gt 0 ]]; then
  if [[ "$(uname)" == "Darwin" ]]; then
    # macOS find
    find_time_args=(-mtime "-$DAYS_BACK")
  else
    # GNU find
    find_time_args=(-mtime "-$DAYS_BACK")
  fi
fi

# 输出文件
MANIFEST="$OUTDIR/storage-files-$stamp.csv"
{
  echo "path,filename,ext,size,modified_iso,owner,storage_root,relative_to_home"
} > "$MANIFEST"

total=0
total_size=0
for path in "${final_paths[@]}"; do
  storage_label=$(basename "$path")

  # 用 -print0 安全处理
  while IFS= read -r -d '' f; do
    [[ -f "$f" ]] || continue
    [[ -L "$f" ]] && continue  # 跳过软链

    ext="${f##*.}"
    ext_lc=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    size=$(stat -f %z "$f" 2>/dev/null || stat -c %s "$f" 2>/dev/null || echo 0)
    mtime_iso=$(stat -f "%Sm" -t "%Y-%m-%dT%H:%M:%S%z" "$f" 2>/dev/null \
               || stat -c "%y" "$f" 2>/dev/null | cut -d. -f1)
    owner=$(stat -f %Su "$f" 2>/dev/null || stat -c %U "$f" 2>/dev/null || echo "unknown")
    rel="${f#$HOME/}"
    [[ "$rel" == "$f" ]] && rel="$f"

    # CSV 字段
    safe_f=$(echo "$f" | tr -d '"')
    safe_rel=$(echo "$rel" | tr -d '"')
    safe_subj=$(echo "${f##*/}" | tr -d '"')

    echo "\"$safe_f\",\"$safe_subj\",\"$ext_lc\",$size,\"$mtime_iso\",\"$owner\",\"$storage_label\",\"$safe_rel\"" >> "$MANIFEST"
    total=$((total + 1))
    total_size=$((total_size + size))
  done < <(find "$path" \
    "${exclude_args[@]}" \
    -type f \
    "${find_time_args[@]}" \
    \( \
      \( -name "*.doc" -o -name "*.docx" -o -name "*.docm" -o -name "*.dot" -o -name "*.dotx" \) -o \
      \( -name "*.xls" -o -name "*.xlsx" -o -name "*.xlsm" -o -name "*.csv" -o -name "*.xlsb" -o -name "*.ods" \) -o \
      \( -name "*.ppt" -o -name "*.pptx" -o -name "*.pptm" -o -name "*.ppsx" -o -name "*.odp" \) -o \
      -name "*.pdf" -o \
      -name "*.wps" -o -name "*.rtf" -o -name "*.odt" -o -name "*.pages" -o -name "*.numbers" -o -name "*.key" -o \
      -name "*.eml" -o -name "*.msg" -o -name "*.mbox" -o -name "*.pst" -o -name "*.ost" -o \
      -name "*.txt" -o -name "*.md" -o -name "*.markdown" -o -name "*.rst" -o -name "*.log" -o \
      -name "*.json" -o -name "*.yaml" -o -name "*.yml" -o -name "*.toml" -o -name "*.ini" -o -name "*.conf" -o -name "*.cfg" -o -name "*.properties" -o \
      -name "*.xml" -o -name "*.html" -o -name "*.htm" -o \
      \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.tsx" -o -name "*.jsx" -o -name "*.java" -o -name "*.kt" -o -name "*.go" -o -name "*.rs" -o -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.hpp" -o -name "*.cs" -o -name "*.rb" -o -name "*.php" -o -name "*.sh" -o -name "*.bash" -o -name "*.sql" -o -name "*.r" -o -name "*.scala" -o -name "*.lua" -o -name "*.swift" -o -name "*.dart" \) -o \
      \( -name "*.db" -o -name "*.sqlite" -o -name "*.sqlite3" -o -name "*.mdb" -o -name "*.accdb" -o -name "*.dbf" \) -o \
      \( -name "*.psd" -o -name "*.ai" -o -name "*.sketch" -o -name "*.fig" -o -name "*.xd" -o -name "*.indd" \) -o \
      \( -name "*.zip" -o -name "*.rar" -o -name "*.7z" -o -name "*.tar" -o -name "*.gz" -o -name "*.bz2" -o -name "*.xz" \) -o \
      -name "*.ics" -o -name "*.vcf" -o -name "*.vcs" -o \
      \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.gif" -o -name "*.bmp" -o -name "*.tiff" -o -name "*.webp" -o -name "*.heic" \) \
    \) \
    -print0 2>/dev/null)
done

# 大小格式
size_human=$(numfmt --to=iec $total_size 2>/dev/null || echo "${total_size}B")

echo ""
echo "✅ 扫描完成: $total 个文件,总大小 $size_human"
echo "📄 Manifest: $MANIFEST"

# Top extensions
echo ""
echo "=== Top 20 文件扩展名 ==="
awk -F',' 'NR>1 {gsub(/"/, "", $3); ext=$3; if (ext) c[ext]++} END {for (e in c) print c[e], e}' "$MANIFEST" | sort -rn | head -20

# Top 存储根
echo ""
echo "=== 存储根分布 ==="
awk -F',' 'NR>1 {gsub(/"/, "", $7); c[$7]++} END {for (k in c) print c[k], k}' "$MANIFEST" | sort -rn

# Top 修改月份
echo ""
echo "=== Top 10 月份(文件数) ==="
awk -F',' 'NR>1 {gsub(/"/, "", $5); print substr($5,1,7)}' "$MANIFEST" | sort | uniq -c | sort -rn | head -10

# JSON
if [[ $JSON -eq 1 ]]; then
  json="$OUTDIR/storage-files-$stamp.json"
  {
    echo "{"
    echo "  \"scan_time\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\","
    echo "  \"total_files\": $total,"
    echo "  \"total_size_bytes\": $total_size,"
    echo "  \"total_size_human\": \"$size_human\","
    echo "  \"storage_roots\": ["
    sep=""
    for p in "${final_paths[@]}"; do
      rp=$(echo "$p" | tr -d '"')
      echo "    $sep\"$rp\""
      sep=","
    done
    echo "  ],"
    echo "  \"manifest_csv\": \"$MANIFEST\""
    echo "}"
  } > "$json"
  echo ""
  echo "📄 JSON: $json"
fi

echo ""
echo "💡 提示:"
echo "  - 这个 manifest 证明你'什么时候在用这些文件'"
echo "  - 配合 scripts/weekly-hash.sh 上链"
echo "  - 配合 scripts/evidence-aggregator.sh 汇总进 case-brief"
echo "  - ⚠️  注意:不要上传到公司云盘,只在本机 + 个人云"
