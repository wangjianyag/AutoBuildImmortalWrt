#!/bin/bash
# 该文件实际为imagebuilder容器内的build.sh
# yml 传入的路由器型号 PROFILE
echo "Building for profile: $PROFILE"
echo "Include Docker: $INCLUDE_DOCKER"
echo "Create pppoe-settings"
mkdir -p  /home/build/immortalwrt/files/etc/config

# 创建pppoe配置文件 yml传入pppoe变量————>pppoe-settings文件
cat << EOF > /home/build/immortalwrt/files/etc/config/pppoe-settings
enable_pppoe=${ENABLE_PPPOE}
pppoe_account=${PPPOE_ACCOUNT}
pppoe_password=${PPPOE_PASSWORD}
EOF

echo "cat pppoe-settings"
cat /home/build/immortalwrt/files/etc/config/pppoe-settings

# 输出调试信息
echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting build process..."


# 定义所需安装的包列表 下列插件你都可以自行删减
PACKAGES=""
PACKAGES="$PACKAGES curl"
PACKAGES="$PACKAGES luci-i18n-firewall-zh-cn"
PACKAGES="$PACKAGES luci-i18n-filebrowser-zh-cn"
PACKAGES="$PACKAGES luci-app-argon-config"
PACKAGES="$PACKAGES luci-i18n-argon-config-zh-cn"
PACKAGES="$PACKAGES luci-i18n-diskman-zh-cn"
#23.05
PACKAGES="$PACKAGES luci-i18n-opkg-zh-cn"
PACKAGES="$PACKAGES luci-i18n-ttyd-zh-cn"
PACKAGES="$PACKAGES luci-i18n-passwall-zh-cn"
PACKAGES="$PACKAGES luci-app-openclash"
PACKAGES="$PACKAGES luci-i18n-ramfree-zh-cn"
PACKAGES="$PACKAGES openssh-sftp-server"
PACKAGES="$PACKAGES luci-app-ddnsto"
PACKAGES="$PACKAGES luci-app-adguardhome"
PACKAGES="$PACKAGES luci-app-airplay2"
# 增加几个必备组件 方便用户安装iStore
PACKAGES="$PACKAGES fdisk"
PACKAGES="$PACKAGES script-utils"
PACKAGES="$PACKAGES luci-i18n-samba4-zh-cn"
# 增加几个必备组件 用于GL.iNet GL-MT3000 接入中兴F50
PACKAGES="$PACKAGES usb-modeswitch"
PACKAGES="$PACKAGES usbmuxd"
PACKAGES="$PACKAGES kmod-usb-acm"
PACKAGES="$PACKAGES kmod-usb-core"
PACKAGES="$PACKAGES kmod-usb-ehci"
PACKAGES="$PACKAGES kmod-usb-net"
PACKAGES="$PACKAGES kmod-usb-net-cdc-ether"
PACKAGES="$PACKAGES kmod-usb-net-cdc-ncm"
PACKAGES="$PACKAGES kmod-usb-net-huawei-cdc-ncm"
PACKAGES="$PACKAGES kmod-usb-net-ipheth"
PACKAGES="$PACKAGES kmod-usb-net-kalmia"
PACKAGES="$PACKAGES kmod-usb-net-qmi-wwan"
PACKAGES="$PACKAGES kmod-usb-net-rndis"
PACKAGES="$PACKAGES kmod-usb-ohci"
PACKAGES="$PACKAGES kmod-usb-serial"
PACKAGES="$PACKAGES kmod-usb-serial-option"
PACKAGES="$PACKAGES kmod-usb-serial-wwan"
PACKAGES="$PACKAGES kmod-usb-storage"
PACKAGES="$PACKAGES kmod-usb-storage-uas"
PACKAGES="$PACKAGES kmod-usb-uhci"
PACKAGES="$PACKAGES kmod-usb-wdm"
PACKAGES="$PACKAGES kmod-usb2"
PACKAGES="$PACKAGES kmod-usb3"
PACKAGES="$PACKAGES libusb-1.0-0"
PACKAGES="$PACKAGES libusbmuxd"

# 判断是否需要编译 Docker 插件
if [ "$INCLUDE_DOCKER" = "yes" ]; then
    PACKAGES="$PACKAGES luci-i18n-dockerman-zh-cn"
    echo "Adding package: luci-i18n-dockerman-zh-cn"
fi


# 构建镜像
echo "$(date '+%Y-%m-%d %H:%M:%S') - Building image with the following packages:"
echo "$PACKAGES"

make image PROFILE=$PROFILE PACKAGES="$PACKAGES" FILES="/home/build/immortalwrt/files"

if [ $? -ne 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: Build failed!"
    exit 1
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - Build completed successfully."
