FROM debian:bullseye-slim

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    fuse \
    curl \
    wget \
    sed \
    file \
    jq \
    libgl1 \
    libnss3 \
    libxrandr2 \
    libasound2 \
    libegl1 \
    libglib2.0-dev

RUN curl -s https://api.github.com/repos/linuxdeploy/linuxdeploy/releases \
  | jq '.[0] .assets[] | .browser_download_url | select(endswith("linuxdeploy-x86_64.AppImage"))' \
  | xargs wget -O /usr/local/bin/linuxdeploy -q

RUN chmod +x /usr/local/bin/linuxdeploy
