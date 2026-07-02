#!/usr/bin/env bash
# evidence-scanner.sh - 扫描本地可作为证据的痕迹(只读,不导出)
# 适用:程序员/通用岗;输出 evidence-scan.json 供人审查
# 用法: bash scripts/evidence-scanner.sh [--root PATH] [--output PATH] [--json]
set -euo pipefail

ROOT="${HOME:-/Users/$(whoami)}"
OUTPUT="$HOME/evidence-scan.json"
JSON=0
[[ "${1:-}" == "--json" ]] && JSON=1
while [[ $# -gt 0 ]]; do
  case "$1" in
    --root) ROOT="$2"; shift 2;;
    --output) OUTPUT="$2"; shift 2;;
    --json) JSON=1; shift;;
    *) shift;;
  esac
done

WARN='\033[0;33m'; OK='\033[0;32m'; NC='\033[0m'
hits=()

scan() {
  local pattern="$1" label="$2" risk="${3:-medium}"
  if command -v find >/dev/null 2>&1; then
    while IFS= read -r -d '' f; do
      hits+=("{\"type\":\"$label\",\"file\":\"$f\",\"risk\":\"$risk\"}")
    done < <(find "$ROOT" -maxdepth 6 -type f -name "$pattern" 2>/dev/null -print0)
  fi
}

# === 程序员痕迹 ===
scan "*.git" "git_repo" "high"
scan "*.pem" "ssh_key" "low"
scan "id_rsa*" "ssh_key" "low"
scan ".gitconfig" "git_identity" "low"
scan ".npmrc" "npmrc" "low"
scan ".pypirc" "pypirc" "low"
scan ".docker" "docker_dir" "low"
scan "Dockerfile" "dockerfile" "low"
scan "*.kubeconfig" "kubeconfig" "low"
scan "*.tfstate" "terraform_state" "high"
scan "deploy*.log" "deploy_log" "high"
scan "*.har" "http_archive" "high"
scan "*.postman_collection.json" "postman" "low"

# === 通用痕迹 ===
scan "*.eml" "email" "medium"
scan "*.msg" "email_outlook" "medium"
scan "*.mbox" "mbox" "medium"
scan "*.ics" "calendar" "low"
scan "*.vcf" "contact" "low"
scan "Notes.md" "notes" "low"
scan "TODO.md" "notes" "low"

# === 通用 office 文件 ===
scan "*.docx" "office_doc" "medium"
scan "*.xlsx" "office_xls" "medium"
scan "*.pptx" "office_ppt" "medium"
scan "*.pdf" "office_pdf" "medium"

# 汇总
total=${#hits[@]}
echo -e "${WARN}=== Evidence Scan Report ===${NC}"
echo -e "扫描根: $ROOT"
echo -e "命中: $total 项"
for h in "${hits[@]:0:30}"; do
  type=$(echo "$h" | sed -E 's/.*"type":"([^"]+)".*/\1/')
  file=$(echo "$h" | sed -E 's/.*"file":"([^"]+)".*/\1/')
  risk=$(echo "$h" | sed -E 's/.*"risk":"([^"]+)".*/\1/')
  case "$risk" in
    high) color="$WARN";;
    low)  color="$OK";;
    *)    color="$NC";;
  esac
  echo -e "  [$color$risk$NC] [$type] $file"
done
[[ $total -gt 30 ]] && echo "  ... 还有 $((total-30)) 项"

if [[ $JSON -eq 1 ]]; then
  {
    echo "{"
    echo "  \"scan_time\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\","
    echo "  \"root\": \"$ROOT\","
    echo "  \"total_hits\": $total,"
    echo "  \"items\": ["
    for i in "${!hits[@]}"; do
      sep=","; [[ $i -eq 0 ]] && sep=""
      echo "    ${sep}${hits[$i]}"
    done
    echo "  ]"
    echo "}"
  } > "$OUTPUT"
  echo -e "${OK}JSON 报告已写入: $OUTPUT${NC}"
fi

echo -e "\n${WARN}=== 提示 ===${NC}"
echo "1. 命中仅意味着'存在'，不意味'有证据价值',需人工审查"
echo "2. 不要把这些路径上传云端,可能含密钥/隐私"
echo "3. 下一步: bash scripts/evidence-collector.sh --plan"
