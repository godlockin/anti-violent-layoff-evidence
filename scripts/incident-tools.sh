#!/usr/bin/env bash
# incident-tools.sh - 60 秒应急工具集
# 被锁号后,此脚本将在私人设备上完成核心取证导出
set -euo pipefail

BLUE='\033[0;34m'; RED='\033[0;31m'; NC='\033[0m'

step() { echo -e "\n${BLUE}[$1]${NC} $2"; }
die()  { echo -e "${RED}[ERR]${NC} $*" >&2; exit 1; }

incident_dir="$HOME/evidence/incident/$(date +%Y-%m-%d)-incident"
mkdir -p "$incident_dir"/{emails,chats,recordings}

step 0 "60 秒应急检查表"
cat <<'EOF'
□ 深呼吸,不签字
□ 手机录音笔同时开
□ 给家人发坐标 + 一句话
□ 个人云盘连接验证(坚果云/百度网盘)
□ 个人邮箱登录测试
□ 私人 4G/5G,不要用公司 WiFi
EOF

step 1 "创建事件目录"
echo "$incident_dir"

step 2 "收集已知邮件导出"
echo -e "提示:用 Thunderbird/Outlook 在本机登录,导出 mbox 到 ${incident_dir}/emails\n"

step 3 "收集即时通信截图"
cat <<'EOF'
# 钉钉: 设置 → 数据 → 导出聊天记录
# 飞书: 设置 → 数据导出
# 微信: 迁移聊天记录到另一台设备
# Slack: Settings → Data export → Download
EOF

step 4 "找工作记录备份"
echo "目标文件路径: ~/evidence/2024-Q1/ 等"

step 5 "对全证据 hash"
if [[ -d "$HOME/evidence" ]]; then
  echo -e "执行: bash $(dirname "$0")/weekly-hash.sh"
  echo -e "这将登记所有证据 sha256,后续可上链"
fi

step 6 "推送应急包到可信人"
cat <<'EOF'
# 加密压缩
cd "$HOME/evidence"
tar -czf - incident/2026-*-incident/ | openssl enc -aes-256-gcm -salt -pbkdf2 -out incident-enc.tar.gz.enc
# 发送到: 你信任的家人/律师邮箱(只用 私人 邮箱)
EOF

step 7 "联系律师"
cat <<'EOF'
# 律师紧急联系方式保存
# 中国法律服务网: 12348
# 人社维权: 12333
# 法律援助(免费): 当地法律援助中心,持身份证申请
EOF

echo -e "\n${RED}=== 提醒:任何时候你都有拒绝签字、要求当面录像、不当面对峙的权利 ===${NC}"
echo -e "${RED}=== 谈判时多要 30 分钟、要求回家看、要求书面通知 ===${NC}"
