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
curl -s https://install.speedtest.net/app/cli/install.deb.sh | sudo bash
apt-get install speedtest -y
mkdir /root/.config/
mkdir /root/.config/ookla/

  cat > '/root/.config/ookla/speedtest-cli.json' << EOF
{
    "Settings": {
        "LicenseAccepted": "604ec27f828456331ebf441826292c49276bd3c1bee1a2f65a6452f505c4061c"
    }
}
EOF

TERM=ansi whiptail --title "带宽测试" --infobox "带宽测试，请耐心等待。" 7 68
echo "YES" | /usr/bin/speedtest
/usr/bin/speedtest -f json | tee /root/.trojan/speed.json
port_down=$( jq -r '.download.bandwidth' "/root/.trojan/speed.json" )
port_up=$( jq -r '.upload.bandwidth' "/root/.trojan/speed.json" )

apt install bc -y

if (( $(echo "$port_up < 3000000" |bc -l) )); then
target_speed_down="30"
target_speed_up="30"
else
target_speed_down_bytes=$( jq -r '.download.bandwidth' "/root/.trojan/speed.json")
target_speed_up_bytes=$( jq -r '.upload.bandwidth' "/root/.trojan/speed.json")
target_speed_down=$(( target_speed_down_bytes*76294/10000000000 ))
target_speed_up=$(( target_speed_up_bytes*76294/10000000000 ))
echo $target_speed_down
echo $target_speed_up
fi
}