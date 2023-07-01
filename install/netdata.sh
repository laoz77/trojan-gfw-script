#!/usr/bin/env bash

## Netdata模组 Netdata moudle

#---Author Info---
ver="1.0.0"
Author="johnrosen1"
url="https://johnrosen1.com/"
github_url="https://github.com/johnrosen1/vpstoolbox"
#-----------------

set +e

install_netdata(){
clear
TERM=ansi whiptail --title "安装中" --infobox "安装Netdata中..." 7 68
colorEcho ${INFO} "Install netdata ing"
bash <(curl -Ss https://my-netdata.io/kickstart-static64.sh) --dont-wait --static-only --disable-telemetry
sed -i "s/SEND_EMAIL=\"YES\"/SEND_EMAIL=\"NO\"/" /opt/netdata/usr/lib/netdata/conf.d/health_alarm_notify.conf
sed -i "s/Restart=on-failure/Restart=always/" /lib/systemd/system/netdata.service
systemctl daemon-reload
systemctl stop netdata
killall netdata
systemctl enable netdata
systemctl restart netdata
clear
}


