#!/bin/bash
shopt -s extglob

SHELL_FOLDER=$(dirname $(readlink -f "$0"))

bash 5.15.sh

rm -rf package/boot/uboot-envtools package/firmware/ipq-wifi package/firmware/ath11k* package/kernel/mac80211 target/linux/generic
svn export --force https://github.com/robimarko/openwrt/branches/ipq807x-5.15-pr/package/boot/uboot-envtools package/boot/uboot-envtools
svn export --force https://github.com/robimarko/openwrt/branches/ipq807x-5.15-pr/package/firmware/ipq-wifi package/firmware/ipq-wifi
svn export --force https://github.com/robimarko/openwrt/branches/ipq807x-5.15-pr/package/firmware/ath11k-firmware package/firmware/ath11k-firmware
svn export --force https://github.com/robimarko/openwrt/branches/ipq807x-5.15-pr/package/kernel/mac80211 package/kernel/mac80211
svn export --force https://github.com/robimarko/openwrt/branches/ipq807x-5.15-pr/package/kernel/qca-nss-dp package/kernel/qca-nss-dp
svn export --force https://github.com/robimarko/openwrt/branches/ipq807x-5.15-pr/package/kernel/qca-ssdk package/kernel/qca-ssdk

svn co https://github.com/robimarko/openwrt/branches/ipq807x-5.15-pr/target/linux/generic target/linux/generic
rm -rf target/linux/generic/.svn
svn co https://github.com/coolsnowwolf/lede/trunk/target/linux/generic/hack-5.15 target/linux/generic/hack-5.15

svn co https://github.com/robimarko/openwrt/branches/ipq807x-5.15-pr/target/linux/ipq807x target/linux/ipq807x

git clone https://github.com/robimarko/nss-packages --depth 1 package/nss-packages

rm -rf package/network

svn co https://github.com/robimarko/openwrt/branches/ipq807x-5.15-pr/package/network package/network

curl -sfL https://raw.githubusercontent.com/robimarko/openwrt/ipq807x-5.15-pr/include/kernel-5.15 -o include/kernel-5.15
kernel_v="$(cat include/kernel-5.15 | grep LINUX_KERNEL_HASH-* | cut -f 2 -d - | cut -f 1 -d ' ')"
echo "KERNEL=${kernel_v}" >> $GITHUB_ENV || true
sed -i "s?targets/%S/.*'?targets/%S/$kernel_v'?" include/feeds.mk

curl -sfL https://raw.githubusercontent.com/robimarko/openwrt/ipq807x-5.15-pr/package/kernel/linux/modules/netsupport.mk -o package/kernel/linux/modules/netsupport.mk

curl -sfL https://raw.githubusercontent.com/Boos4721/openwrt/master/target/linux/ipq807x/patches-5.15/700-ipq8074-overclock-cpu-2.2ghz.patch -o target/linux/ipq807x/patches-5.15/700-ipq8074-overclock-cpu-2.2ghz.patch

rm -rf package/kernel/mt76

sed -i "s/tty\(0\|1\)::askfirst/tty\1::respawn/g" target/linux/*/base-files/etc/inittab

sed -i '$a  \
CONFIG_CPU_FREQ_GOV_POWERSAVE=y \
CONFIG_CPU_FREQ_GOV_USERSPACE=y \
CONFIG_CPU_FREQ_GOV_ONDEMAND=y \
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y \
' target/linux/ipq807x/config-5.15

echo '修改机器名称'
sed -i 's/OpenWrt/RedmiAX6/g' package/base-files/files/bin/config_generate

echo '修改网关地址'
sed -i 's/192.168.1.1/192.168.31.1/g' package/base-files/files/bin/config_generate

#echo '修改主机名字'
#sed -i '/uci commit system/i\uci set system.@system[0].hostname="Redmi_AX6"' package/lean/default-settings/files/zzz-default-settings

echo '修改连接数'
sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=165535' package/base-files/files/etc/sysctl.conf

echo '修改时区'
sed -i "s/'UTC'/'CST-8'\n        set system.@system[-1].zonename='Asia\/Shanghai'/g" package/base-files/files/bin/config_generate

#echo '修改默认主题'
#sed -i 's/config internal themes/config internal themes\n    option Argon  \"\/luci-static\/argon\"/g' feeds/luci/modules/luci-base/root/etc/config/luci

echo '修改默认wifi名称ssid'
sed -i 's/ssid=OpenWrt/ssid="Redmi AX6"/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh

echo '修改默认wifi加密方式和密码'
sed -i 's/encryption=none/encryption=sae-mixed/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh
sed -i '/set wireless.default_radio${devidx}.encryption=sae-mixed/a\set wireless.default_radio${devidx}.key=password' package/kernel/mac80211/files/lib/wifi/mac80211.sh

#echo '增加schedutil调速器'
#sed -i '/CONFIG_CPU_FREQ_GOV_ONDEMAND=y/a\CONFIG_CPU_FREQ_GOV_SCHEDUTIL=y' target/linux/ipq807x/config-5.15
#sed -i 's/# CONFIG_CPU_FREQ_GOV_SCHEDUTIL is not set/CONFIG_CPU_FREQ_GOV_SCHEDUTIL=y/g' target/linux/ipq807x/config-5.15
#sed -i 's/# CONFIG_CPU_FREQ_GOV_POWERSAVE is not set/CONFIG_CPU_FREQ_GOV_POWERSAVE=y/g' target/linux/ipq807x/config-5.15
#sed -i 's/# CONFIG_CPU_FREQ_STAT is not set/CONFIG_CPU_FREQ_STAT=y/g' target/linux/ipq807x/config-5.15
#sed -i '/CONFIG_CPU_FREQ_GOV_ONDEMAND=y/a\CONFIG_CPU_FREQ_GOV_SCHEDUTIL=y' target/linux/ipq807x/Makefile
sed -i 's/mu_beamformer=0/mu_beamformer=1/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh


echo 'replace coremark.sh with the new one'
cp -f ../coremark.sh feeds/packages/utils/coremark/

echo 'refresh feeds'
./scripts/feeds update -a
./scripts/feeds install -a
echo '首页增加CPU频率动态显示'
cp -f ../diy/mod-index.htm ./feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm

#echo 'enable magic'
#echo 'src-git helloworld https://github.com/fw876/helloworld'>>./feeds.conf.default
#git clone https://github.com/robbyrussell/oh-my-zsh package/base-files/files/root/.oh-my-zsh

# Install extra plugins
#git clone https://github.com/zsh-users/zsh-autosuggestions package/base-files/files/root/.oh-my-zsh/custom/plugins/zsh-autosuggestions
#git clone https://github.com/zsh-users/zsh-syntax-highlighting.git package/base-files/files/root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
#git clone https://github.com/zsh-users/zsh-completions package/base-files/files/root/.oh-my-zsh/custom/plugins/zsh-completions

