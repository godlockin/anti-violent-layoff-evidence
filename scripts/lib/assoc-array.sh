#!/usr/bin/env bash
# lib/assoc-array.sh - macOS bash 3.2 关联数组 polyfill
# 加载后,以下函数可用:
#   assoc_put NAME KEY VALUE
#   assoc_get NAME KEY
#   assoc_has NAME KEY
#   assoc_keys NAME
#   assoc_del NAME KEY
# 内部:用 ${NAME_DIR}/NAME 目录存 value 文件

assoc_init() {
  local name="$1"
  local dir="${AVLE_ASSOC_DIR:-/tmp/avle_assoc}"
  mkdir -p "$dir"
  eval "${name}_DIR=\"$dir\""
}

assoc_put() {
  local name="$1" key="$2" value="$3"
  local dir_var="${name}_DIR"
  local dir="${!dir_var}"
  mkdir -p "$dir/$name"
  echo "$value" > "$dir/$name/$key"
}

assoc_get() {
  local name="$1" key="$2"
  local dir_var="${name}_DIR"
  local dir="${!dir_var}"
  [[ -f "$dir/$name/$key" ]] && cat "$dir/$name/$key" || echo ""
}

assoc_has() {
  local name="$1" key="$2"
  local dir_var="${name}_DIR"
  local dir="${!dir_var}"
  [[ -f "$dir/$name/$key" ]]
}

assoc_keys() {
  local name="$1"
  local dir_var="${name}_DIR"
  local dir="${!dir_var}"
  [[ -d "$dir/$name" ]] && ls "$dir/$name" 2>/dev/null
}

assoc_del() {
  local name="$1" key="$2"
  local dir_var="${name}_DIR"
  local dir="${!dir_var}"
  rm -f "$dir/$name/$key"
}

# Auto-init
assoc_init DEFAULT 2>/dev/null || true
