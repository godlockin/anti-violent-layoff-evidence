#!/usr/bin/env bash
# rust-accel.sh - rust 工具加速 wrapper
# 自动探测已安装的 rust 工具(fd/eza/rg/bat/delta/dust/procs),有则用,无则 fallback
#
# 用法 1 (作为 lib):
#   source scripts/rust-accel.sh
#   f_run /path pattern              # 用 fd 或 find
#   l_run /path                      # 用 eza 或 ls
#   g_run pattern /path              # 用 rg 或 grep
#
# 用法 2 (作为 CLI):
#   bash scripts/rust-accel.sh detect                # 列出可用工具
#   bash scripts/rust-accel.sh bench                 # 跑性能对比
#   bash scripts/rust-accel.sh install-hints         # 提示安装命令
#
# 设计原则:不强制安装,纯 fallback,无副作用
set -eo pipefail

# ===== 工具状态缓存(macOS bash 3.2 兼容:用临时文件) =====
AVLE_TOOL_DIR=$(mktemp -d -t avle_tools.XXXXXX)
trap 'rm -rf "$AVLE_TOOL_DIR"' EXIT

_avle_tool_has() {
  [[ -f "$AVLE_TOOL_DIR/$1.path" ]]
}

_avle_tool_path() {
  [[ -f "$AVLE_TOOL_DIR/$1.path" ]] && cat "$AVLE_TOOL_DIR/$1.path" || echo ""
}

_avle_tool_ver() {
  [[ -f "$AVLE_TOOL_DIR/$1.ver" ]] && cat "$AVLE_TOOL_DIR/$1.ver" || echo ""
}

# 探测单个工具
_avle_detect_one() {
  local tool="$1"
  if command -v "$tool" >/dev/null 2>&1; then
    command -v "$tool" > "$AVLE_TOOL_DIR/$tool.path"
    # 获取版本
    local ver=""
    case "$tool" in
      fd)     ver="$(fd --version 2>&1 | head -1)";;
      eza)    ver="$(eza --version 2>&1 | head -1)";;
      rg)     ver="$(rg --version 2>&1 | head -1)";;
      bat)    ver="$(bat --version 2>&1 | head -1)";;
      delta)  ver="$(delta --version 2>&1 | head -1)";;
      dust)   ver="$(dust --version 2>&1 | head -1)";;
      procs)  ver="$(procs --version 2>&1 | head -1)";;
      zoxide) ver="$(zoxide --version 2>&1 | head -1)";;
      tokei)  ver="$(tokei --version 2>&1 | head -1)";;
      *)      ver="(unknown version)";;
    esac
    echo "$ver" > "$AVLE_TOOL_DIR/$tool.ver"
    return 0
  else
    rm -f "$AVLE_TOOL_DIR/$tool.path" "$AVLE_TOOL_DIR/$tool.ver"
    return 1
  fi
}

# 全部探测
avle_detect_all() {
  for t in fd eza rg bat delta dust procs zoxide tokei hyperfine sd xh; do
    _avle_detect_one "$t" || true
  done
}

# 列出已装工具
avle_detect() {
  avle_detect_all
  echo "🔍 rust 工具探测结果 / rust tool detection"
  echo ""
  printf "%-12s %-8s %s\n" "TOOL" "STATUS" "VERSION / PATH"
  printf "%-12s %-8s %s\n" "────" "──────" "─────────────"
  for t in fd eza rg bat delta dust procs zoxide tokei hyperfine sd xh; do
    if _avle_tool_has "$t"; then
      printf "${GREEN}%-12s${NC} %-8s %s\n" "$t" "✓ 已有" "$(_avle_tool_ver "$t")"
    else
      printf "%-12s %-8s %s\n" "$t" "✗ 缺失" "(未安装)"
    fi
  done
  echo ""
  echo "💡 缺失的工具可装:brew install <tool>  或  cargo install <tool>"
}

# 加速版本:find -> fd
f_run() {
  # f_run <path> [pattern] [extra args...]
  local path="$1"
  shift
  if _avle_tool_has fd; then
    # fd 默认排除 .git
    if [[ $# -eq 0 ]]; then
      fd --type f --hidden --no-ignore --exclude ".git" --exclude "node_modules" --exclude "target" --exclude ".Trash" . "$path" 2>/dev/null
    else
      local pat="$1"; shift
      fd --type f --hidden --no-ignore --exclude ".git" --exclude "node_modules" --exclude "target" --exclude ".Trash" "$pat" "$path" 2>/dev/null
    fi
  else
    # fallback: find + macOS bash 3.2 兼容
    find "$path" -type f \
      -not -path "*/.git/*" \
      -not -path "*/node_modules/*" \
      -not -path "*/target/*" \
      -not -path "*/.Trash/*" \
      "$@" 2>/dev/null
  fi
}

# 加速版本:ls -la -> eza
l_run() {
  if _avle_tool_has eza; then
    eza -la --git --no-permissions --no-user --time-style=long-iso "$@" 2>/dev/null || ls -la "$@"
  else
    ls -la "$@"
  fi
}

# 加速版本:grep -r -> rg
g_run() {
  # g_run <pattern> <path> [extra args...]
  local pat="$1"
  local path="$2"
  shift 2
  if _avle_tool_has rg; then
    rg --no-heading --line-number --color never "$pat" "$path" "$@" 2>/dev/null
  else
    grep -rn "$pat" "$path" "$@" 2>/dev/null
  fi
}

# 加速版本:cat -> bat
c_run() {
  if _avle_tool_has bat; then
    bat --plain --paging never --color never "$@" 2>/dev/null || cat "$@"
  else
    cat "$@"
  fi
}

# 加速版本:du -sh -> dust
d_run() {
  if _avle_tool_has dust; then
    dust --no-percent-bars -d 1 "$@" 2>/dev/null || du -sh "$@"
  else
    du -sh "$@" 2>/dev/null
  fi
}

# 加速版本:ps -> procs
p_run() {
  if _avle_tool_has procs; then
    procs "$@" 2>/dev/null || ps aux
  else
    ps aux
  fi
}

# 性能对比:find vs fd
bench_fd() {
  echo "🚀 性能对比 / Benchmark: find vs fd (扫描 ~/)"
  echo ""
  local target="${1:-$HOME}"
  local pattern="${2:-*.pdf}"
  local max_depth="${3:-4}"  # 默认 4 层,避免大 ~ 太久

  # 暖机
  f_run "$target" "$pattern" >/dev/null 2>&1 || true

  echo "测试目标: $target"
  echo "模式: $pattern"
  echo "深度: -$max_depth"
  echo ""

  # find
  echo "⏱️  find:"
  local t1 t2
  t1=$(date +%s.%N)
  local n_find
  n_find=$(find "$target" -maxdepth "$max_depth" -type f -name "$pattern" 2>/dev/null | wc -l | tr -d ' ')
  t2=$(date +%s.%N)
  local dur_find
  dur_find=$(awk "BEGIN {printf \"%.2f\", $t2 - $t1}")
  echo "   $dur_find s, 命中 $n_find 个"
  echo ""

  # fd
  if _avle_tool_has fd; then
    echo "⏱️  fd:"
    t1=$(date +%s.%N)
    local n_fd
    local fd_pat="${pattern//\*/.*}"
    n_fd=$(fd --type f --max-depth "$max_depth" --regex "$fd_pat" "$target" 2>/dev/null | wc -l | tr -d ' ')
    t2=$(date +%s.%N)
    local dur_fd
    dur_fd=$(awk "BEGIN {printf \"%.2f\", $t2 - $t1}")
    echo "   $dur_fd s, 命中 $n_fd 个"
    echo ""

    if [[ $(awk "BEGIN {print ($dur_fd > 0 && $dur_find > 0)}") -eq 1 ]]; then
      local speedup
      speedup=$(awk "BEGIN {printf \"%.1f\", $dur_find / $dur_fd}")
      echo "🎯 fd 加速: ${speedup}x"
    fi
  else
    echo "⏭️  fd 未安装,跳过对比"
  fi
}

# 性能对比:grep vs rg
bench_rg() {
  echo ""
  echo "🚀 性能对比 / Benchmark: grep -r vs rg (在 ~/evidence)"
  echo ""
  local target="${1:-$HOME/evidence}"
  local pattern="${2:-COMPANY}"

  [[ -d "$target" ]] || { echo "目标不存在: $target"; return 1; }

  echo "⏱️  grep -rn:"
  local t1 t2
  t1=$(date +%s.%N)
  local n_grep
  n_grep=$(grep -rn "$pattern" "$target" 2>/dev/null | wc -l | tr -d ' ')
  t2=$(date +%s.%N)
  local dur_grep
  dur_grep=$(awk "BEGIN {printf \"%.2f\", $t2 - $t1}")
  echo "   $dur_grep s, 命中 $n_grep 行"
  echo ""

  if _avle_tool_has rg; then
    echo "⏱️  rg:"
    t1=$(date +%s.%N)
    local n_rg
    n_rg=$(rg --no-heading "$pattern" "$target" 2>/dev/null | wc -l | tr -d ' ')
    t2=$(date +%s.%N)
    local dur_rg
    dur_rg=$(awk "BEGIN {printf \"%.2f\", $t2 - $t1}")
    echo "   $dur_rg s, 命中 $n_rg 行"
    echo ""

    if [[ $(awk "BEGIN {print ($dur_rg > 0 && $dur_grep > 0)}") -eq 1 ]]; then
      local speedup
      speedup=$(awk "BEGIN {printf \"%.1f\", $dur_grep / $dur_rg}")
      echo "🎯 rg 加速: ${speedup}x"
    fi
  fi
}

# 跑全部 bench
bench_all() {
  bench_fd
  bench_rg
}

# 安装提示
install_hints() {
  echo "💡 rust 加速器安装提示"
  echo ""
  echo "## macOS (推荐用 Homebrew)"
  echo ""
  echo "  brew install fd eza ripgrep bat git-delta dust procs zoxide tokei"
  echo ""
  echo "## Ubuntu/Debian"
  echo ""
  echo "  # fd"
  echo "  sudo apt install fd-find ripgrep bat"
  echo "  # 其他需要 cargo"
  echo "  cargo install eza procs dust tokei zoxide"
  echo ""
  echo "## Arch"
  echo ""
  echo "  sudo pacman -S fd eza ripgrep bat git-delta dust procs"
  echo ""
  echo "## Windows (Scoop)"
  echo ""
  echo "  scoop install fd eza ripgrep bat delta dust procs"
  echo ""
  echo "## 各工具用途 / What each tool does"
  echo ""
  echo "  fd       - 替代 find(快 5-10x,语法更友好)"
  echo "  eza      - 替代 ls(更好看 + git status 集成)"
  echo "  ripgrep  - 替代 grep -r(快 5-20x,.gitignore 自动跳过)"
  echo "  bat      - 替代 cat(语法高亮 + 分页)"
  echo "  delta    - 替代 diff(更好看的 git diff)"
  echo "  dust     - 替代 du(可视化,看哪个目录占空间)"
  echo "  procs    - 替代 ps(更好看的进程列表)"
  echo "  zoxide   - 智能 cd(基于历史)"
  echo "  tokei    - 代码行数统计(替代 cloc)"
  echo "  hyperfine - 性能 bench 工具"
  echo "  sd       - 替代 sed(更易用的文本替换)"
  echo "  xh       - 替代 curl(更友好的 HTTP 客户端)"
}

# CLI 入口
if [[ "${BASH_SOURCE[0]:-$0}" == "${0}" ]]; then
  # 探测一次
  avle_detect_all

  case "${1:-detect}" in
    detect)        avle_detect;;
    bench)         shift; bench_all "$@";;
    bench-fd)      shift; bench_fd "$@";;
    bench-rg)      shift; bench_rg "$@";;
    install-hints) install_hints;;
    -h|--help|help)
      cat <<'EOF'
AVLE rust 加速器

用法:
  bash scripts/rust-accel.sh detect          探测已装工具
  bash scripts/rust-accel.sh bench           跑性能对比
  bash scripts/rust-accel.sh bench-fd        单跑 find vs fd
  bash scripts/rust-accel.sh bench-rg        单跑 grep vs rg
  bash scripts/rust-accel.sh install-hints   安装提示

作为 lib 引用:
  source scripts/rust-accel.sh
  f_run /path pattern            # fd / find
  l_run /path                    # eza / ls
  g_run pattern /path            # rg / grep
  c_run file                     # bat / cat
  d_run /path                    # dust / du
  p_run                          # procs / ps
EOF
      ;;
    *)
      echo "Unknown subcommand: $1" >&2
      exit 1
      ;;
  esac
fi
