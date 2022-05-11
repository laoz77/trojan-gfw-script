#!/usr/bin/env bash

## Speedtest_cli 模组

#---Author Info---
ver="1.0.0"
Author="johnrosen1"
url="https://johnrosen1.com/"
github_url="https://github.com/johnrosen1/vpstoolbox"
#-----------------

set +e

mycountry="$( jq -r '.country' "/root/.trojan/ip.json" )"

install_speed(){
# https://github.com/sivel/speedtest-cli
apt install pip -y
pip install speedtest-cli
TERM=ansi whiptail --title "带宽测试" --infobox "带宽测试，请耐心等待。" 7 68
speedtest-cli --list
speedtest-cli --secure --no-upload --json | tee /root/.trojan/speed_ping.json
ping_result=$( jq -r '.ping' "/root/.trojan/speed_ping.json" )

if (( $(echo "$ping_result < 10" |bc -l) )); then
speedtest-cli --secure | tee /root/.trojan/speed.txt
speedtest-cli --secure --json | tee /root/.trojan/speed.json
elif [[ ${mycountry} == "JP" ]]
# speedtest-cli --secure --server 48296 | tee /root/.trojan/speed.txt
# speedtest-cli --secure --server 48296 --json | tee /root/.trojan/speed.json
speedtest-cli --secure | tee /root/.trojan/speed.txt
speedtest-cli --secure --json | tee /root/.trojan/speed.json
else
speedtest-cli --secure | tee /root/.trojan/speed.txt
speedtest-cli --secure --json | tee /root/.trojan/speed.json
fi

apt install bc -y

port_down=$( jq -r '.download' "/root/.trojan/speed.json" )
port_up=$( jq -r '.upload' "/root/.trojan/speed.json" )

if (( $(echo "$port_up < 100000000" |bc -l) )); then
target_speed_down="100"
target_speed_up="100"
else
target_speed_down=$( jq -r '.download' "/root/.trojan/speed.json" | cut -c1-3)
target_speed_up=$( jq -r '.upload' "/root/.trojan/speed.json" | cut -c1-3)
fi
}