#!/usr/bin/env bash

## RSS模组 RSS moudle

set +e

install_rss(){
cd /usr/share/nginx/

## Install Miniflux

cd /usr/share/nginx/

mkdir miniflux
mkdir rsshub

cd /usr/share/nginx/rsshub

mkdir /usr/share/nginx/rsshub/redis

cat > "/usr/share/nginx/rsshub/docker-compose.yml" << EOF
version: '3.8'
services:
  rsshub: # 1200
    network_mode: host
    image: diygod/rsshub
    container_name: rsshub
    # ports:
    #   - '1200:1200'
    environment:
      # PROXY_URI: 'http://127.0.0.1:8080'
      NODE_ENV: production
      CACHE_TYPE: redis
      REDIS_URL: 'redis://redis:6379/'
      PUPPETEER_WS_ENDPOINT: 'ws://browserless:3000'
    depends_on:
      - browserless
      - redis
    restart: always
  browserless: # 3000
    image: browserless/chrome
    container_name: browserless
    restart: always
    ports:
      - 127.0.0.1:3000:3000
  redis:
    image: redis:alpine
    restart: always
    volumes:
      - /usr/share/nginx/rsshub/redis:/data
EOF
docker-compose up -d --remove-orphans

cd /usr/share/nginx/miniflux

cat > "/usr/share/nginx/miniflux/docker-compose.yml" << EOF
version: '3.4'
services:
  miniflux:
    image: miniflux/miniflux:latest
    restart: always
    ports:
      - "8080:8080"
    depends_on:
      - db
    environment:
      - DATABASE_URL=postgres://miniflux:adminadmin@db/miniflux?sslmode=disable
      - BASE_URL=https://${domain}/miniflux/
      - RUN_MIGRATIONS=1
      - CREATE_ADMIN=1
      - ADMIN_USERNAME=admin
      - ADMIN_PASSWORD=adminadmin
  db:
    image: postgres:latest
    restart: always
    environment:
      - POSTGRES_USER=miniflux
      - POSTGRES_PASSWORD=adminadmin
    volumes:
      - miniflux-db:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "miniflux"]
      interval: 10s
      start_period: 30s
volumes:
  miniflux-db:
EOF
#sed -i "s/adminadmin/${password1}/g" docker-compose.yml
docker-compose up -d --remove-orphans
}