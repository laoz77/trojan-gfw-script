#!/usr/bin/env bash

## OUTPUT模组 Output moudle

set +e

prase_output(){

if [[ ${warp_v6} == 1 ]] || [[ ${warp_v4} == 1 ]]; then
myip=${domain}
fi

if [[ ${warp_plus} == 1 ]]; then
myipv6="Warp+v6"
fi

clear
	cat > '/etc/profile.d/mymotd.sh' << EOF
#!/usr/bin/env bash
bold=\$(tput bold)
normal=\$(tput sgr0)
# ----------------------------------
# Colors
# ----------------------------------
NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'
###
domain="${domain}"
trojanport="${trojanport}"
password1="${password1}"
password2="${password2}"
neofetch
echo -e " --- 欢迎使用VPSToolBox 😀😀😀 --- "
echo -e " --- \${BLUE}服務狀態(Service Status)\${NOCOLOR} ---"
  if [[ \$(cat /etc/sysctl.conf | grep bbr) = *bbr* ]] ; then
echo -e "BBR网络优化:\t\t 已开启"
  fi
  if [[ \$(systemctl is-active wg-quick@wgcf.service) == active ]]; then
echo -e "Warp+ Teams:\t\t 正常运行中"
  fi
  if [[ \$(systemctl is-active trojan) == active ]]; then
echo -e "Trojan-GFW:\t\t 正常运行中"
  fi
  if [[ \$(systemctl is-active grpc) == active ]]; then
echo -e "Vless(Grpc):\t\t 正常运行中"
  fi
  if [[ \$(systemctl is-active hysteria) == active ]]; then
echo -e "Hysteria:\t\t 正常运行中"
  fi
  if [[ \$(systemctl is-active ssserver) == active ]]; then
echo -e "SS-rust:\t\t 正常运行中"
  fi
  if [[ \$(systemctl is-active nginx) == active ]]; then
echo -e "Nginx:\t\t\t 正常运行中"
  fi
  if [[ \$(systemctl is-active hexo) == active ]]; then
echo -e "Hexo:\t\t\t 正常运行中"
  fi
  if [[ \$(systemctl is-active qbittorrent) == active ]]; then
echo -e "Qbittorrent:\t\t 正常运行中"
  fi
  if [[ \$(systemctl is-active tracker) == active ]]; then
echo -e "Bittorrent-tracker:\t 正常运行中"
  fi
  if [[ \$(systemctl is-active aria2) == active ]]; then
echo -e "Aria2c:\t\t\t 正常运行中"
  fi
  if [[ \$(systemctl is-active filebrowser) == active ]]; then
echo -e "Filebrowser:\t\t 正常运行中"
  fi
  if [[ \$(systemctl is-active netdata) == active ]]; then
echo -e "Netdata:\t\t 正常运行中"
  fi
  if [[ \$(systemctl is-active docker) == active ]]; then
echo -e "Docker:\t\t\t 正常运行中"
  fi
  if [[ \$(systemctl is-active mariadb) == active ]]; then
echo -e "MariaDB:\t\t 正常运行中"
  fi
  if [[ \$(systemctl is-active dovecot) == active ]]; then
echo -e "Dovecot:\t\t 正常运行中"
  fi
  if [[ \$(systemctl is-active postfix) == active ]]; then
echo -e "Postfix:\t\t 正常运行中"
  fi
  if [[ \$(systemctl is-active fail2ban) == active ]]; then
echo -e "Fail2ban:\t\t 正常运行中"
  fi
echo -e " --- \${BLUE}防火墙状态(NAT Type)\${NOCOLOR} ---"
echo '\n' | pystun3 | grep -i "NAT Type"
echo -e " --- \${BLUE}端口速率(Port speed)\${NOCOLOR} ---"
echo -e "下载(⬇️): ${target_speed_down} Mbps"
echo -e "上传(⬆️): ${target_speed_up} Mbps"
echo -e " --- \${BLUE}三网速率(China route speed)\${NOCOLOR} ---"
echo -e "中国电信(CT): ${ct_up} ⬆️ ${ct_down} ⬇️ Mbps ${ct_latency} ms"
echo -e "中国联通(CU): ${cu_up} ⬆️ ${cu_down} ⬇️ Mbps ${cu_latency} ms"
echo -e "中国移动(CM): ${cm_up} ⬆️ ${cm_down} ⬇️ Mbps ${cm_latency} ms"
echo -e " --- \${BLUE}带宽使用(Bandwith Usage)\${NOCOLOR} ---"
echo -e "         接收(Receive)    发送(Transmit)"
tail -n +3 /proc/net/dev | grep -e eth -e enp -e eno -e ens | awk '{print \$1 " " \$2 " " \$10}' | numfmt --to=iec --field=2,3
echo -e " --- \${GREEN}證書狀態(Certificate Status)\${NOCOLOR} ---"
ssl_date=\$(echo |timeout 3 openssl s_client -4 -connect ${myip}:${trojanport} -servername ${domain} -tls1_3 2>&1 |sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p'|openssl x509 -text) &>/dev/null
tmp_last_date=\$(echo "\${ssl_date}" | grep 'Not After :' | awk -F' : ' '{print \$NF}')
last_date=\$(date -ud "\${tmp_last_date}" +%Y-%m-%d" "%H:%M:%S)
day_count=\$(( (\$(date -d "\${last_date}" +%s) - \$(date +%s))/(24*60*60) ))
echo -e "\e[40;33;1m [${domain}] 证书过期日期 : [\${last_date}] 剩余 [\${day_count}] 天 \e[0m"
echo -e "*******************************************************************"
if [[ -f /usr/bin/xray ]]; then
echo -e " --- \${BLUE}Vless 链接(低延迟 低并发 支持Cloudflare CDN)\${NOCOLOR} ---"
echo -e "    \${YELLOW}vless://${uuid_new}@${myip}:${trojanport}?mode=multi&security=tls&type=grpc&serviceName=${path_new}&sni=${domain}#Vless(${route_final}${mycountry} ${mycity} ${myip} ${myipv6} ${target_speed_up} Mbps)\${NOCOLOR}"
echo -e " --- \${BLUE}Vless 二维码\${NOCOLOR} ---"
  qrencode -t UTF8 -m 2 "vless://${uuid_new}@${myip}:${trojanport}?mode=multi&security=tls&type=grpc&serviceName=${path_new}&sni=${domain}#Vless(${route_final}${mycountry} ${mycity} ${myip} ${myipv6} ${target_speed_up} Mbps)"
echo -e " --- \${BLUE}Trojan-GFW 链接(高延迟 高并发 不支持Cloudflare CDN)"
echo -e "    \${YELLOW}trojan://${password1}@${myip}:${trojanport}?security=tls&headerType=none&type=tcp&sni=${domain}#Trojan(${route_final}${mycountry} ${mycity} ${myip} ${myipv6} ${target_speed_up} Mbps)\${NOCOLOR}"
echo -e " --- \${BLUE}Trojan-GFW 二维码\${NOCOLOR} ---"
  qrencode -t UTF8 -m 2 "trojan://${password1}@${myip}:${trojanport}?security=tls&headerType=none&type=tcp&sni=${domain}#Trojan(${route_final}${mycountry} ${mycity} ${myip} ${myipv6} ${target_speed_up} Mbps)"
else
echo -e " --- \${BLUE}Trojan-GFW 链接(不支持Cloudflare CDN)\${NOCOLOR} ---"
echo -e "    \${YELLOW}trojan://${password1}@${myip}:${trojanport}?security=tls&headerType=none&type=tcp&sni=${domain}#Trojan(${route_final}${mycountry} ${mycity} ${myip} ${myipv6} ${target_speed_up} Mbps)\${NOCOLOR}"
echo -e " --- \${BLUE}Trojan-GFW 二维码\${NOCOLOR} ---"
  qrencode -t UTF8 -m 2 "trojan://${password1}@${myip}:${trojanport}?security=tls&headerType=none&type=tcp&sni=${domain}#Trojan(${route_final}${mycountry} ${mycity} ${myip} ${myipv6} ${target_speed_up} Mbps)"
fi
if [[ -f /usr/sbin/ssserver ]]; then
echo -e " --- \${BLUE}SS-rust 链接\${NOCOLOR} ---"
echo -e "    \${YELLOW}ss://2022-blake3-aes-128-gcm:${password1}@${myip}:8388#SS(${route_final}${mycountry} ${mycity} ${myip} ${myipv6} ${target_speed_up} Mbps)\${NOCOLOR}"
echo -e "    \${YELLOW}ss://$(echo "2022-blake3-aes-128-gcm:${password1}@${myip}:8388" | base64)#SS(${route_final}${mycountry} ${mycity} ${myip} ${myipv6} ${target_speed_up} Mbps)\${NOCOLOR}"
echo -e " --- \${BLUE}SS-rust 二维码\${NOCOLOR} ---"
  qrencode -t UTF8 -m 2 "ss://2022-blake3-aes-128-gcm:${password1}@${myip}:8388#SS(${route_final}${mycountry} ${mycity} ${myip} ${myipv6} ${target_speed_up} Mbps)"
fi
if [[ -f /usr/bin/hysteria ]]; then
echo -e " --- \${BLUE}Hysteria 链接\${NOCOLOR} ---"
echo -e "    \${YELLOW}hysteria://${myip}:${hyport}?protocol=udp&peer=${domain}&upmbps=${target_speed_down}&downmbps=${target_speed_up}&alpn=h3&obfsParam=${password1}#HY(${route_final}${mycountry} ${mycity} ${myip} ${myipv6} ${target_speed_up} Mbps)\${NOCOLOR}"
echo -e " --- \${BLUE}Hysteria 二维码\${NOCOLOR} ---"
  qrencode -t UTF8 -m 2 "hysteria://${myip}:${hyport}?protocol=udp&peer=${domain}&upmbps=${target_speed_down}&downmbps=${target_speed_up}&alpn=h3&obfsParam=${password1}#HY(${route_final}${mycountry} ${mycity} ${myip} ${myipv6} ${target_speed_up} Mbps)"
fi
echo -e " --- \${BLUE}Trojan-GFW 可用性检测链接(被墙检测链接)\${NOCOLOR} ---"
echo -e "    \${YELLOW}https://tcp.ping.pe/${myip}:${trojanport}\${NOCOLOR}"
echo -e " --- \${BLUE}推荐的 Trojan/Vless 客户端(安卓,苹果,Windows)\${NOCOLOR} ---"
echo -e "    \${YELLOW}https://github.com/2dust/v2rayNG/releases/latest\${NOCOLOR}"
echo -e "    \${YELLOW}https://apps.apple.com/us/app/shadowrocket/id932747118\${NOCOLOR}"
echo -e "    \${YELLOW}https://github.com/2dust/v2rayN/releases/latest\${NOCOLOR}"
if [[ -d /usr/share/nginx/nextcloud/ ]]; then
echo -e " --- \${BLUE}Nextcloud 链接\${NOCOLOR}(Nextcloud links) ---"
echo -e "    \${YELLOW}https://${domain}:${trojanport}/nextcloud/\${NOCOLOR}"
echo -e "    \${YELLOW}用户名: admin\${NOCOLOR}"
echo -e "    \${YELLOW}密码: ${password1}\${NOCOLOR}"
fi
if [[ -d /usr/share/nginx/miniflux/ ]]; then
echo -e " --- \${BLUE}Miniflux+RSSHUB 链接\${NOCOLOR} ---"
echo -e "    \${YELLOW}https://$domain:${trojanport}/miniflux/\${NOCOLOR}"
echo -e "    \${YELLOW}用户名: admin\${NOCOLOR}"
echo -e "    \${YELLOW}密码: ${password1}\${NOCOLOR}"
echo -e "    \${YELLOW}https://$domain:${trojanport}/rsshub/\${NOCOLOR}"
fi
if [[ -d /etc/filebrowser/ ]]; then
echo -e " --- \${BLUE}Filebrowser 链接\${NOCOLOR} ---"
echo -e "    \${YELLOW}https://$domain:${trojanport}/file/\${NOCOLOR}"
echo -e "    \${YELLOW}用户名: admin\${NOCOLOR}"
echo -e "    \${YELLOW}密码: admin\${NOCOLOR}"
fi
if [[ -d /usr/share/nginx/speedtest/ ]]; then
echo -e " --- \${BLUE}Speedtest 链接\${NOCOLOR} ---"
echo -e "    \${YELLOW}https://$domain:${trojanport}/${password1}_speedtest/\${NOCOLOR}"
fi
if [[ -d /usr/share/nginx/nzbget ]]; then
echo -e " --- \${BLUE}影音链接\${NOCOLOR} ---"
echo -e "    \${YELLOW}https://$domain:${trojanport}/emby/\${NOCOLOR}"
echo -e "    \${YELLOW}https://$domain:${trojanport}/ombi/\${NOCOLOR}"
echo -e "    \${YELLOW}https://$domain:${trojanport}/sonarr/\${NOCOLOR}"
echo -e "    \${YELLOW}https://$domain:${trojanport}/radarr/\${NOCOLOR}"
echo -e "    \${YELLOW}https://$domain:${trojanport}/lidarr/\${NOCOLOR}"
echo -e "    \${YELLOW}https://$domain:${trojanport}/readarr/\${NOCOLOR}"
echo -e "    \${YELLOW}https://$domain:${trojanport}/bazarr/\${NOCOLOR}"
echo -e "    \${YELLOW}https://$domain:${trojanport}/chinesesubfinder/\${NOCOLOR}"
echo -e "    \${YELLOW}https://$domain:${trojanport}/prowlarr/\${NOCOLOR}"
echo -e "    \${YELLOW}https://$domain:${trojanport}/nzbget/\${NOCOLOR}"
fi
if [[ -d /etc/aria2/ ]]; then
echo -e " --- \${BLUE}AriaNG+Aria2 链接\${NOCOLOR} ---"
echo -e "    \${YELLOW}https://$domain:${trojanport}/ariang/\${NOCOLOR}"
echo -e "    \${YELLOW}密码: ${ariapasswd}\${NOCOLOR}"
echo -e "    \${YELLOW}https://$domain:${trojanport}${ariapath}\${NOCOLOR}"
fi
if [[ -d /usr/share/nginx/qBittorrent/ ]]; then
echo -e " --- \${BLUE}Qbittorrent 链接\${NOCOLOR} ---"
echo -e "    \${YELLOW}https://$domain:${trojanport}/qbt/\${NOCOLOR}"
echo -e "    \${YELLOW}用户名: admin\${NOCOLOR}"
echo -e "    \${YELLOW}密码: ${password1}\${NOCOLOR}"
fi
if [[ -d /opt/netdata/ ]]; then
echo -e " --- \${BLUE}Netdata 链接\${NOCOLOR} ---"
echo -e "    \${YELLOW}https://$domain:${trojanport}/${password1}_netdata/\${NOCOLOR}"
fi
if [[ -d /usr/share/nginx/rocketchat ]]; then
echo -e " --- \${BLUE}Rocketchat 链接\${NOCOLOR} ---"
echo -e "    \${YELLOW}https://$domain:${trojanport}/chat/\${NOCOLOR}"
fi
if [[ -d /opt/alist ]]; then
echo -e " --- \${BLUE}Alist 链接\${NOCOLOR} ---"
cd /opt/alist
alist_password=\$(./alist -password | awk -F'your password: ' '{print \$2}' 2>&1)
cd
echo -e "    \${YELLOW}https://$domain:${trojanport}\${NOCOLOR}"
echo -e "    \${YELLOW}密码: \${alist_password}\${NOCOLOR}"
fi
echo -e " --- \${BLUE}Telegram 群组链接\${NOCOLOR} ---"
echo -e "    \${YELLOW}https://t.me/vpstoolbox_chat\${NOCOLOR}"
echo -e "*********************"
EOF
chmod +x /etc/profile.d/mymotd.sh
echo "" > /etc/motd
echo "Install complete!"
whiptail --title "Success" --msgbox "安装成功(Install Success),欢迎使用VPSTOOLBOX !" 8 68
clear
bash /etc/profile.d/mymotd.sh
}
