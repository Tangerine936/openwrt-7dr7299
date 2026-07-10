#!/bin/bash
set -e -o pipefail

echo "=== diy-script: 开始自定义编译配置 ==="

# 移除要替换的包
#移除luci-app-attendedsysupgrade
sed -i "/attendedsysupgrade/d" $(find ./feeds/luci/collections/ -type f -name "Makefile")

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# 添加额外插件

#luci-theme-argon
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-argon-config
git clone --depth=1 -b openwrt-25.12 https://github.com/Tangerine936/luci-theme-argon package/luci-theme-argon

#passwall
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}
rm -rf feeds/luci/applications/luci-app-passwall
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall-packages package/passwall-packages
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall package/passwall-luci
#git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall2 package/passwall2-luci
#sed -i "s/146fa4511a52da2aaa1e11ea0294cfb450e62643156c5da3b10e037ef43961f6/42dab453a7d8b3737109110083513467bad1cf71a0aaf671452595797b2b59b0/g" package/passwall-packages/shadowsocksr-libev/Makefile

#dae
rm -rf feeds/luci/applications/luci-app-daed
rm -rf feeds/packages/net/daed
git clone --depth=1 https://github.com/QiuSimons/luci-app-daed package/dae

#openclash
rm -rf feeds/luci/applications/luci-app-openclash
git_sparse_clone master https://github.com/vernesong/OpenClash luci-app-openclash

#luci-app-mini-diskmanager
git clone --depth=1 https://github.com/4IceG/luci-app-mini-diskmanager package/luci-app-mini-diskmanager

#luci-app-partexp
git clone --depth=1 https://github.com/sirpdboy/luci-app-partexp package/luci-app-partexp

#wolplus
git_sparse_clone main https://github.com/VIKINGYFY/packages luci-app-wolplus

#netspeedtest
git clone --depth=1 https://github.com/sirpdboy/netspeedtest.git package/netspeedtest

#5G CPE
rm -rf package/mtk/applications/5g-modem
git clone --depth=1 https://github.com/FUjr/QModem.git package/qmodem

#修改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-argon/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#修改immortalwrt.lan关联IP
sed -i "s/192\.168\.[0-9]*\.[0-9]*/192.168.6.1/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")
#添加编译日期标识
sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ $WRT_MARK-$WRT_DATE')/g" $(find ./feeds/luci/modules/luci-mod-status/ -type f -name "10_system.js")
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/192.168.6.1/g" package/base-files/files/bin/config_generate
# 修改版本为编译日期
DATE_VERSION="$(date +%Y.%m.%d)"
VERSION_FILE="include/version.mk"
echo "[diy] 修改版本为编译日期: $DATE_VERSION"
sed -i "s/^VERSION_NUMBER:=.*/VERSION_NUMBER:=-$DATE_VERSION by Tangerine936/" "$VERSION_FILE"
#TTYD 免登录
sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config

./scripts/feeds install -a


echo "=== diy-script: 完成 ==="
