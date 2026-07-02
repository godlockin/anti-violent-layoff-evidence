#!/usr/bin/env bash
# evidence-collector.sh - 按计划选择性收集(只读,生成加密归档)
# 默认 dry-run;--apply 才执行加密压缩
# 用法: bash scripts/evidence-collector.sh [--plan | --apply] [--output DIR]
set -euo pipefail

EVIDENCE_ROOT="${EVIDENCE_ROOT:-$HOME/evidence}"
OUTPUT_DIR="${2:-$EVIDENCE_ROOT/collected}"
MODE="plan"
[[ "${1:-}" == "--apply" ]] && MODE="apply"

stamp=$(date +%Y%m%d-%H%M%S)
target_dir="$OUTPUT_DIR/$stamp"
mkdir -p "$target_dir"

declare -a plan=(
  # 类别|模式|说明
  "EMAIL|*.eml *.msg *.mbox|邮件证据"
  "GIT|.git/config|Git 仓库身份证据(不含代码)"
  "GIT_AUTHOR|.gitconfig|Git 作者指纹"
  "DEPLOY_LOG|*.log *.json|部署/CI 日志"
  "TIMECARD|钉钉*.png 打卡*.png 考勤*.png|考勤截图"
  "PAYSLIP|工资*.png 工资条*.pdf|工资条"
  "SOCIAL|个税*.png 社保*.png 公积金*.png|个税/社保/公积金"
  "CONTRACT|劳动合同*.pdf 入职*.pdf Offer*.pdf|劳动合同"
  "OFFICE|*.docx *.xlsx *.pptx *.pdf|工作文件"
  "CHAT|微信记录*.zip 钉钉聊天*.zip 飞书*.zip|聊天记录"
  "NOTE|Notes.md TODO.md *.md *.markdown|工作笔记"
)

echo "=== Evidence Collection Plan ($MODE) ==="
echo "目标: $target_dir"
echo ""
printf "%-12s | %-30s | %s\n" "类别" "匹配模式" "说明"
printf -- "-------------+--------------------------------+----------------\n"
for row in "${plan[@]}"; do
  IFS='|' read -r cat pat desc <<< "$row"
  printf "%-12s | %-30s | %s\n" "$cat" "$pat" "$desc"
done

if [[ "$MODE" == "plan" ]]; then
  echo ""
  echo "⚠️  当前为 plan 模式,不会复制任何文件"
  echo "确认后请执行: bash $0 --apply"
  exit 0
fi

echo ""
echo "正在收集到 $target_dir ..."

collected=0
for row in "${plan[@]}"; do
  IFS='|' read -r cat pat desc <<< "$row"
  subdir="$target_dir/$cat"
  mkdir -p "$subdir"

  # 找 HOME 和 Downloads/Desktop/Documents
  for src in "$HOME" "$HOME/Downloads" "$HOME/Desktop" "$HOME/Documents" "$EVIDENCE_ROOT"; do
    [[ -d "$src" ]] || continue
    # shellcheck disable=SC2086
    while IFS= read -r -d '' f; do
      base=$(basename "$f")
      cp -p "$f" "$subdir/${src##*/}_$base" 2>/dev/null && collected=$((collected+1))
    done < <(find "$src" -maxdepth 4 -type f \( $(printf -- "-name %s -o " $pat) -false \) -print0 2>/dev/null)
  done
done

echo "✅ 收集 $collected 个文件到 $target_dir"

# 计算 hash
echo ""
echo "计算 SHA256 ..."
{
  echo "filename,sha256,size,collected_at"
  while IFS= read -r -d '' f; do
    hash=$(shasum -a 256 "$f" 2>/dev/null | awk '{print $1}')
    size=$(stat -f %z "$f" 2>/dev/null || stat -c %s "$f" 2>/dev/null || echo 0)
    rel="${f#$target_dir/}"
    echo "\"$rel\",\"$hash\",\"$size\",\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
  done < <(find "$target_dir" -type f -print0)
} > "$target_dir/manifest.csv"

echo "✅ Manifest: $target_dir/manifest.csv"

# 加密打包
echo ""
echo "加密打包 (AES-256-GCM) ..."
cd "$OUTPUT_DIR"
archive="$OUTPUT_DIR/evidence-$stamp.tar.gz.enc"

if command -v openssl >/dev/null 2>&1; then
  # 提示用户输入密码(可空)
  if [[ -t 0 ]]; then
    echo -n "请设置加密密码(可回车跳过,只用 tar 打包): "
    read -r -s PWD
    echo ""
  else
    PWD=""
  fi
  if [[ -n "${PWD:-}" ]]; then
    tar -czf - "$stamp" | openssl enc -aes-256-gcm -salt -pbkdf2 -pass "pass:$PWD" -out "$archive"
    echo "✅ 加密归档: $archive"
  else
    tar -czf "$OUTPUT_DIR/evidence-$stamp.tar.gz" "$stamp"
    echo "✅ 普通归档: $OUTPUT_DIR/evidence-$stamp.tar.gz (无加密)"
  fi
fi

echo ""
echo "=== Done ==="
echo "下一步: 把 $target_dir 复制到:"
echo "  - 个人云盘(坚果云/百度网盘)"
echo "  - U 盘 + 信任的家人物业"
echo "  - 个人邮箱(可分卷发送)"
