#!/usr/bin/env bash

## opentracker模组 opentracker moudle

set +e

install_tracker(){
  TERM=ansi whiptail --title "安装中" --infobox "安装Bittorrent-tracker中" 7 68
colorEcho ${INFO} "Install Bittorrent-tracker ing"
apt-get install libowfat-dev make git build-essential zlib1g-dev libowfat-dev make git -y
useradd -r opentracker --shell=/usr/sbin/nologin
git clone https://erdgeist.org/gitweb/opentracker opentracker
cd opentracker
#sed -i 's/#FEATURES+=-DWANT_V6/FEATURES+=-DWANT_V6/' Makefile
sed -i 's/#FEATURES+=-DWANT_IP_FROM_QUERY_STRING/FEATURES+=-DWANT_IP_FROM_QUERY_STRING/' Makefile
sed -i 's/#FEATURES+=-DWANT_COMPRESSION_GZIP/FEATURES+=-DWANT_COMPRESSION_GZIP/' Makefile
sed -i 's/#FEATURES+=-DWANT_IP_FROM_PROXY/FEATURES+=-DWANT_IP_FROM_PROXY/' Makefile
sed -i 's/#FEATURES+=-DWANT_LOG_NUMWANT/FEATURES+=-DWANT_LOG_NUMWANT/' Makefile
sed -i 's/#FEATURES+=-DWANT_SYSLOGS/FEATURES+=-DWANT_SYSLOGS/' Makefile
sed -i 's/#FEATURES+=-DWANT_FULLLOG_NETWORKS/FEATURES+=-DWANT_FULLLOG_NETWORKS/' Makefile
#sed -i 's/#FEATURES+=-DWANT_SYNC_LIVE/FEATURES+=-DWANT_SYNC_LIVE/' Makefile
make
cp -f opentracker /usr/sbin/opentracker
  cat > '/etc/systemd/system/tracker.service' << EOF
[Unit]
Description=Bittorrent-Tracker Daemon Service
Documentation=https://erdgeist.org/arts/software/opentracker/
Wants=network-online.target
After=network-online.target nss-lookup.target

[Service]
Type=simple
User=opentracker
Group=opentracker
RemainAfterExit=yes
ExecStart=/usr/sbin/opentracker -d /etc/opentracker
TimeoutStopSec=infinity
LimitNOFILE=infinity
Restart=on-failure
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF
mkdir /etc/opentracker
systemctl daemon-reload
systemctl enable tracker --now
cd /usr/share/nginx/
mkdir tracker
cd /usr/share/nginx/tracker/
  cat > 'stats.js' << EOF
function addDataToPage(xmlDocument, type) {
  const torrents = xmlDocument.querySelector("torrents count_mutex").textContent;
  const peers = xmlDocument.querySelector("peers count").textContent;
  const seeds = xmlDocument.querySelector("seeds count").textContent;
  const uptime = xmlDocument.querySelector("uptime").textContent;

  document.getElementById("torrents" + type + "Count").textContent = torrents;
  document.getElementById("peers" + type + "Count").textContent = peers;
  document.getElementById("seeds" + type + "Count").textContent = seeds;
  document.getElementById("uptime" + type).textContent = uptime;
}

function refreshData(type) {
  const url = "https://${domain}/tracker_stats/stats?mode=everything";

  fetch(url)
    .then(response => response.text())
    // https://stackoverflow.com/a/41009103
    .then(xml => (new window.DOMParser()).parseFromString(xml, "application/xml"))
    .then(xmlDocument => addDataToPage(xmlDocument, type))
    .catch(console.error);
}

refreshData(4);
refreshData(6);

window.setInterval(function(){
  refreshData(4);
  refreshData(6);
}, 1000);
EOF

  cat > 'index.html' << EOF

<!doctype html>
<html lang="zh-tw">
<head>

<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>My opentracker</title>
<meta name="description" content="My bittorrent tracker instance powered by opentracker">
<link rel="stylesheet" href="/libs/normalize/normalize.css">
<!-- <link rel="stylesheet" href="/assets/fonts.css"> -->

<style>
body {
  margin: 20px;
  font-family: 'Open Sans', sans-serif;
}
</style>

</head>
<body>


<h1>opentracker</h1>
<hr>

<p>My <a href="https://erdgeist.org/arts/software/opentracker/">erdgeist opentracker</a> instance.</p>

<a name="stats"><h3>Stats (IPv4)</h3>

<ul>
  <li>Torrents: <code id="torrents4Count"></code></li>
  <li>Peers: <code id="peers4Count"></code></li>
  <li>Seeds: <code id="seeds4Count"></code></li>

  <li>Uptime: <code id="uptime4"></code></li>
</ul>

<p><a href="https://${domain}/tracker_stats/stats?mode=everything">everything</a> | <a href="https://${domain}/tracker_stats/stats?mode=top100">top100</a></p>

<a name="stats6"><h3>Stats (IPv6)</h3>

<ul>
  <li>Torrents: <code id="torrents6Count"></code></li>
  <li>Peers: <code id="peers6Count"></code></li>
  <li>Seeds: <code id="seeds6Count"></code></li>

  <li>Uptime: <code id="uptime6"></code></li>
</ul>

<p><a href="https://${domain}/tracker_stats/stats?mode=everything">everything</a> | <a href="https://${domain}/tracker_stats/stats?mode=top100">top100</a></p>

<h3>Usage</h3>

<p>Add these trackers to the tracker list of a torrent in your torrent client (such as <a href="https://tixati.com/">tixati</a>, <a href="https://www.qbittorrent.org/">qbittorrent</a>, <a href="https://www.deluge-torrent.org/">deluge</a>):</p>

<pre>
udp://${domain}:6969/announce
</pre>

<p>A plaintext HTTP version is also available, but use of it is discouraged. Please don't add both to help keep load lower on the tracker.</p>

<p>Read more about trackers at <a href="https://support.tixati.com/edit%20trackers">Tixati support</a>.</p>

<h3>Other trackers you may want to use</h3>

<pre>
udp://tracker.iamhansen.xyz:2000/announce

udp://tracker.torrent.eu.org:451/announce

udp://tracker.coppersurfer.tk:6969/announce
</pre>

<p>Other trackers can be found from <a href="https://github.com/ngosang/trackerslist">here</a>.</p>

<h3>Problems?</h3>

<p>You can contact me at <a href="mailto:admin@${domain}">admin@${domain}</a>.</p>
<p>For copyright, etc., contact me at <a href="mailto:admin@${domain}">admin@${domain}</a>.</p>

<hr>

<a href="/">${domain}</a>

<script src="./stats.js"></script>
</body>
</html>
EOF
wget https://raw.githubusercontent.com/necolas/normalize.css/master/normalize.css
cd
rm -rf opentracker
}