#!/bin/bash
set -e -o pipefail

#清除登录密码
sed -i 's/^root:.*$/root:::0:99999:7:::/' package/base-files/files/etc/shadow
#更新golang
rm -rf feeds/packages/lang/golang
git clone --depth=1 -b 26.x https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang
./scripts/feeds install -a

# 同步仓库内维护的 patches 目录到 OpenWrt 源码树
if [ -d "$GITHUB_WORKSPACE/patches/6.6" ]; then
  echo "[diy] 同步自定义 patches/6.6 目录到源码树"
  cp -rf "$GITHUB_WORKSPACE/patches/6.6/." ./
else
  echo "[diy] patches/6.6 目录不存在，跳过"
fi
