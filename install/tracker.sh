#!/usr/bin/env bash

## tracker 模组 tracker moudle

set +e

install_tracker(){

colorEcho ${INFO} "Install Bittorrent-tracker ing"

wget https://dl.google.com/go/go1.19.1.linux-amd64.tar.gz
tar -xzvf go*.tar.gz -C /usr/bin

echo "export PATH=$PATH:/usr/bin/go/bin" > ~/.bash_profile

source ~/.bash_profile

cd /root

git clone https://github.com/chihaya/chihaya.git
cd chihaya
go build ./cmd/chihaya
cp chihaya /usr/sbin/chihaya

cd /root

rm -rf chihaya

  cat > '/etc/systemd/system/tracker.service' << EOF
[Unit]
Description=Bittorrent-Tracker Daemon Service
Documentation=https://github.com/chihaya/chihaya
Wants=network-online.target
After=network-online.target nss-lookup.target

[Service]
Type=simple
User=root
Group=root
RemainAfterExit=yes
ExecStart=/usr/sbin/chihaya --config /etc/chihaya/config.yaml
TimeoutStopSec=infinity
LimitNOFILE=infinity
Restart=on-failure
RestartSec=1s
Nice=-18

[Install]
WantedBy=multi-user.target
EOF

mkdir /etc/chihaya

  cat > '/etc/chihaya/config.yaml' << EOF
---
chihaya:
  # The interval communicated with BitTorrent clients informing them how
  # frequently they should announce in between client events.
  announce_interval: "15m"

  # The interval communicated with BitTorrent clients informing them of the
  # minimal duration between announces.
  min_announce_interval: "5m"

  # The network interface that will bind to an HTTP endpoint that can be
  # scraped by programs collecting metrics.
  #
  # /metrics serves metrics in the Prometheus format
  # /debug/pprof/{cmdline,profile,symbol,trace} serves profiles in the pprof format
  metrics_addr: "127.0.0.1:6880"

  # This block defines configuration for the tracker's HTTP interface.
  # If you do not wish to run this, delete this section.
  http:
    # The network interface that will bind to an HTTP server for serving
    # BitTorrent traffic. Remove this to disable the non-TLS listener.
    addr: "127.0.0.1:6969"

    # The network interface that will bind to an HTTPS server for serving
    # BitTorrent traffic. If set, tls_cert_path and tls_key_path are required.
    https_addr: ""

    # The path to the required files to listen via HTTPS.
    tls_cert_path: ""
    tls_key_path: ""

    # The timeout durations for HTTP requests.
    read_timeout: "5s"
    write_timeout: "5s"

    # When true, persistent connections will be allowed. Generally this is not
    # useful for a public tracker, but helps performance in some cases (use of
    # a reverse proxy, or when there are few clients issuing many requests).
    enable_keepalive: true
    idle_timeout: "30s"

    # Whether to time requests.
    # Disabling this should increase performance/decrease load.
    enable_request_timing: false

    # An array of routes to listen on for announce requests. This is an option
    # to support trackers that do not listen for /announce or need to listen
    # on multiple routes.
    #
    # This supports named parameters and catch-all parameters as described at
    # https://github.com/julienschmidt/httprouter#named-parameters
    announce_routes:
      - "/announce"
      # - "/announce.php"

    # An array of routes to listen on for scrape requests. This is an option
    # to support trackers that do not listen for /scrape or need to listen
    # on multiple routes.
    #
    # This supports named parameters and catch-all parameters as described at
    # https://github.com/julienschmidt/httprouter#named-parameters
    scrape_routes:
      - "/scrape"
      # - "/scrape.php"

    # When enabled, the IP address used to connect to the tracker will not
    # override the value clients advertise as their IP address.
    allow_ip_spoofing: false

    # The HTTP Header containing the IP address of the client.
    # This is only necessary if using a reverse proxy.
    real_ip_header: "x-real-ip"

    # The maximum number of peers returned for an individual request.
    max_numwant: 100

    # The default number of peers returned for an individual request.
    default_numwant: 100

    # The maximum number of infohashes that can be scraped in one request.
    max_scrape_infohashes: 1

  # This block defines configuration for the tracker's UDP interface.
  # If you do not wish to run this, delete this section.
  #udp:
    # The network interface that will bind to a UDP server for serving
    # BitTorrent traffic.
    #addr: "0.0.0.0:6969"

    # The leeway for a timestamp on a connection ID.
    #max_clock_skew: "10s"

    # The key used to encrypt connection IDs.
    #private_key: "paste a random string here that will be used to hmac connection IDs"

    # Whether to time requests.
    # Disabling this should increase performance/decrease load.
    #enable_request_timing: false

    # When enabled, the IP address used to connect to the tracker will not
    # override the value clients advertise as their IP address.
    #allow_ip_spoofing: false

    # The maximum number of peers returned for an individual request.
    #max_numwant: 100

    # The default number of peers returned for an individual request.
    #default_numwant: 50

    # The maximum number of infohashes that can be scraped in one request.
    #max_scrape_infohashes: 50


  # This block defines configuration used for the storage of peer data.
  #storage:
    #name: "memory"
    #config:
      # The frequency which stale peers are removed.
      # This balances between
      # - collecting garbage more often, potentially using more CPU time, but potentially using less memory (lower value)
      # - collecting garbage less frequently, saving CPU time, but keeping old peers long, thus using more memory (higher value).
      #gc_interval: "3m"

      # The amount of time until a peer is considered stale.
      # To avoid churn, keep this slightly larger than `announce_interval`
      #peer_lifetime: "31m"

      # The number of partitions data will be divided into in order to provide a
      # higher degree of parallelism.
      #shard_count: 1024

      # The interval at which metrics about the number of infohashes and peers
      # are collected and posted to Prometheus.
      #prometheus_reporting_interval: "1s"

  # This block defines configuration used for redis storage.
  storage:
     name: redis
     config:
  #     # The frequency which stale peers are removed.
  #     # This balances between
  #     # - collecting garbage more often, potentially using more CPU time, but potentially using less memory (lower value)
  #     # - collecting garbage less frequently, saving CPU time, but keeping old peers long, thus using more memory (higher value).
       gc_interval: "1m"

  #     # The interval at which metrics about the number of infohashes and peers
  #     # are collected and posted to Prometheus.
       prometheus_reporting_interval: "1s"

  #     # The amount of time until a peer is considered stale.
  #     # To avoid churn, keep this slightly larger than `announce_interval`
       peer_lifetime: "31m"

  #     # The address of redis storage.
       redis_broker: "redis://127.0.0.1:6379/0"

  #     # The timeout for reading a command reply from redis.
       redis_read_timeout: "15s"

  #     # The timeout for writing a command to redis.
       redis_write_timeout: "15s"

  #     # The timeout for connecting to redis server.
       redis_connect_timeout: "15s"

  # This block defines configuration used for middleware executed before a
  # response has been returned to a BitTorrent client.
  prehooks:
  # - name: "jwt"
  #   options:
  #     issuer: "https://issuer.com"
  #     audience: "https://chihaya.issuer.com"
  #     jwk_set_url: "https://issuer.com/keys"
  #     jwk_set_update_interval: "5m"

   - name: "client approval"
     options:
  #     whitelist:
  #       - "OP1011"
       blacklist:
         - "XL0012"
         - "XL0018"

   - name: "interval variation"
     options:
       modify_response_probability: 0.8
       max_increase_delta: 300
       modify_min_interval: true

EOF

apt-get install redis-server -y

systemctl daemon-reload
systemctl enable tracker --now
cd
rm -rf opentracker
curl -X POST "https://newtrackon.com/api/add" \
 -H "Content-Type: application/x-www-form-urlencoded" \
 -d new_trackers=http%3A%2F%2F${domain}%3A6969%2Fannounce
}
