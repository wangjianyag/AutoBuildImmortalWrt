#!/bin/sh
# 该脚本为immortalwrt首次启动时 运行的脚本 即 /etc/uci-defaults/99-custom.sh

LOGFILE="/var/log/custom.log"
SETTINGS_FILE="/etc/config/pppoe-settings"

# 设置默认防火墙规则
uci get firewall.@zone[1] >/dev/null 2>&1 && uci set firewall.@zone[1].input='ACCEPT'

# 设置主机名映射
uci add dhcp domain >/dev/null 2>&1 && {
    uci set "dhcp.@domain[-1].name=time.android.com"
    uci set "dhcp.@domain[-1].ip=203.107.6.88"
}

# 检查配置文件是否存在
if [ ! -f "$SETTINGS_FILE" ]; then
    echo "PPPoE settings file not found. Skipping." >> "$LOGFILE"
else
    . "$SETTINGS_FILE"
fi

# 新增USB接口配置
ip link show ETH2 >/dev/null 2>&1 && {
    uci add network interface >/dev/null 2>&1
    uci set network.@interface[-1].name='USB'
    uci set network.@interface[-1].proto='dhcp'
    uci set network.@interface[-1].device='ETH2'
    uci set network.@interface[-1].firewall_zone='wan'
}

# 设置 LAN IP 地址
uci set network.lan.ipaddr='192.168.8.1'
echo "set 192.168.8.1 at $(date)" >> "$LOGFILE"

# 判断是否启用 PPPoE
enable_pppoe=${enable_pppoe:-no}
echo "print enable_pppoe value=== $enable_pppoe" >> "$LOGFILE"
if [ "$enable_pppoe" = "yes" ]; then
    echo "PPPoE is enabled at $(date)" >> "$LOGFILE"
    uci set network.wan.proto='pppoe'
    uci set network.wan.username=${pppoe_account:-''}
    uci set network.wan.password=${pppoe_password:-''}
    uci set network.wan.peerdns='1'
    uci set network.wan.auto='1'
    echo "PPPoE configuration completed successfully." >> "$LOGFILE"
else
    echo "PPPoE is not enabled. Skipping configuration." >> "$LOGFILE"
fi

# 设置所有网口可访问网页终端
uci get ttyd.@ttyd[0] >/dev/null 2>&1 && uci delete ttyd.@ttyd[0].interface

# 设置所有网口可连接 SSH
uci get dropbear.@dropbear[0] >/dev/null 2>&1 && uci set dropbear.@dropbear[0].Interface=''

# 设置编译作者信息
FILE_PATH="/etc/openwrt_release"
NEW_DESCRIPTION="Compiled by wukongdaily"
[ -f "$FILE_PATH" ] && sed -i "s/DISTRIB_DESCRIPTION='[^']*'/DISTRIB_DESCRIPTION='$NEW_DESCRIPTION'/" "$FILE_PATH"

uci commit
exit 0
