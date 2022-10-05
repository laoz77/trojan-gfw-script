#!/usr/bin/env bash

## Alist模组

set +e

install_alist(){
    if [[ -d /opt/alist ]]; then
        curl -fsSL "https://alist.nn.ci/v3.sh" | bash -s update
    else
        curl -fsSL "https://alist.nn.ci/v3.sh" | bash -s install
    fi

  cat > '/etc/systemd/system/alist.service' << EOF
[Unit]
Description=Alist service
Wants=network.target
After=network.target network.service

[Service]
Type=simple
WorkingDirectory=/opt/alist
ExecStart=/opt/alist/alist server 127.0.0.1
KillMode=process
LimitNOFILE=infinity
RestartSec=3s
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable alist
systemctl restart alist
}
