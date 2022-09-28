echo '修改机器名称'
sed -i 's/OpenWrt/RedmiAX6/g' package/base-files/files/bin/config_generate

echo '修改网关地址'
sed -i 's/192.168.1.1/192.168.31.1/g' package/base-files/files/bin/config_generate

echo '修改主机名字'
sed -i '/uci commit system/i\uci set system.@system[0].hostname="Redmi_AX6"' package/lean/default-settings/files/zzz-default-settings

echo '修改连接数'
sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=165535' package/base-files/files/etc/sysctl.conf

echo '修改时区'
sed -i "s/'UTC'/'CST-8'\n        set system.@system[-1].zonename='Asia\/Shanghai'/g" package/base-files/files/bin/config_generate

echo '修改默认主题'
sed -i 's/config internal themes/config internal themes\n    option Argon  \"\/luci-static\/argon\"/g' feeds/luci/modules/luci-base/root/etc/config/luci

echo '修改默认wifi名称ssid'
sed -i 's/ssid=OpenWrt/ssid="Redmi AX6"/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh

echo '修改默认wifi加密方式和密码'
sed -i 's/encryption=none/encryption=sae-mixed/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh
sed -i '/set wireless.default_radio${devidx}.encryption=sae-mixed/a\set wireless.default_radio${devidx}.key=password' package/kernel/mac80211/files/lib/wifi/mac80211.sh

echo '增加schedutil调速器'
sed -i '/CONFIG_CPU_FREQ_GOV_ONDEMAND=y/a\CONFIG_CPU_FREQ_GOV_SCHEDUTIL=y' target/linux/ipq807x/config-5.15
sed -i 's/# CONFIG_CPU_FREQ_GOV_POWERSAVE is not set/CONFIG_CPU_FREQ_GOV_POWERSAVE=y/g' target/linux/ipq807x/config-5.15
sed -i 's/# CONFIG_CPU_FREQ_STAT is not set/CONFIG_CPU_FREQ_STAT=y/g' target/linux/ipq807x/config-5.15
sed -i '/CONFIG_CPU_FREQ_GOV_ONDEMAND=y/a\CONFIG_CPU_FREQ_GOV_SCHEDUTIL=y' target/linux/ipq807x/Makefile
#echo '去除默认bootstrap主题'
#sed -i '/set luci.main.mediaurlbase=\/luci-static\/bootstrap/d' feeds/luci/themes/luci-theme-bootstrap/root/etc/uci-defaults/30_luci-theme-bootstrap


#echo '删除旧版argon,链接新版'
#rm -rf ./package/lean/luci-theme-argon
#git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-theme-argon ../diy/luci-theme-argon
#git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config ../diy/luci-app-argon-config
#ln -s ../../../luci-theme-argon ./package/lean/

echo '下载ServerChan'
git clone https://github.com/tty228/luci-app-serverchan ../diy/luci-app-serverchan

#echo '下载AdGuard Home'
#svn co https://github.com/Lienol/openwrt/trunk/package/diy/luci-app-adguardhome ../diy/luci-app-adguardhome 
#svn co https://github.com/kenzok8/openwrt-packages/trunk/luci-app-adguardhome package/luci-app-adguardhome
#svn co https://github.com/kenzok8/openwrt-packages/trun\\wsl.localhost\Ubuntu\home\zhz\ax6\config\Config-kernel.ink/adguardhome package/adguardhome

#echo '下载pushbot'
#git clone https://github.com/zzsj0928/luci-app-pushbot.git package/luci-app-pushbot

echo '添加smartdns'
svn co https://github.com/kenzok8/openwrt-packages/trunk/smartdns package/smartdns

echo '下载openclash'
git clone -b master --depth 1 https://github.com/vernesong/OpenClash.git package/luci-app-openclash

echo 'replace coremark.sh with the new one'
cp -f ../coremark.sh feeds/packages/utils/coremark/

echo 'refresh feeds'
./scripts/feeds update -a
./scripts/feeds install -a
#echo '首页增加CPU频率动态显示'
#cp -f ../diy/mod-index.htm ./feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm

#echo 'enable magic'
#echo 'src-git helloworld https://github.com/fw876/helloworld'>>./feeds.conf.default
git clone https://github.com/robbyrussell/oh-my-zsh package/base-files/files/root/.oh-my-zsh

# Install extra plugins
git clone https://github.com/zsh-users/zsh-autosuggestions package/base-files/files/root/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git package/base-files/files/root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions package/base-files/files/root/.oh-my-zsh/custom/plugins/zsh-completions

