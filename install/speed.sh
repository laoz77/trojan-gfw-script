#!/usr/bin/env bash

## Speedtest_cli 模组

#---Author Info---
ver="1.0.0"
Author="johnrosen1"
url="https://johnrosen1.com/"
github_url="https://github.com/johnrosen1/vpstoolbox"
#-----------------

set +e

install_speed(){
# https://github.com/sivel/speedtest-cli
apt install pip -y
pip install speedtest-cli
TERM=ansi whiptail --title "带宽测试" --infobox "带宽测试，请耐心等待。" 7 68
speedtest-cli --list
speedtest-cli --secure | tee /root/.trojan/speed.txt
speedtest-cli --secure --json | tee /root/.trojan/speed.json
}