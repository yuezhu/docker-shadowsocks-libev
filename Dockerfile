FROM alpine:3.10

ARG SHADOWSOCKS_LIBEV_VER=3.3.4
ARG V2RAY_PLUGIN_VER=1.3.1
ARG SSL_CERT_GID=115

VOLUME /config

ENV TZ=UTC
ENV ARGS=

RUN \
    apk update && \
    apk add --no-cache --virtual .build-deps \
    autoconf \
    automake \
    build-base \
    c-ares-dev \
    libcap \
    libev-dev \
    libtool \
    libsodium-dev \
    linux-headers \
    mbedtls-dev \
    pcre-dev \
    asciidoc \
    xmlto \
    wget \
    gzip \
    tar

RUN \
    wget -O- "https://github.com/shadowsocks/shadowsocks-libev/releases/download/v${SHADOWSOCKS_LIBEV_VER}/shadowsocks-libev-${SHADOWSOCKS_LIBEV_VER}.tar.gz" | tar xvzf - \
    && cd "shadowsocks-libev-${SHADOWSOCKS_LIBEV_VER}" \
    && ./configure \
    && make install \
    && wget -O- "https://github.com/shadowsocks/v2ray-plugin/releases/download/v${V2RAY_PLUGIN_VER}/v2ray-plugin-linux-amd64-v${V2RAY_PLUGIN_VER}.tar.gz" | tar xvzf - \
    && mv v2ray-plugin_linux_amd64 /usr/local/bin/v2ray-plugin \
    && ls /usr/local/bin/ss-* /usr/local/bin/v2ray-plugin | xargs -n1 setcap cap_net_bind_service+ep \
    && apk del .build-deps \
    && apk add --no-cache \
    ca-certificates \
    rng-tools \
    tzdata \
    $(scanelf --needed --nobanner /usr/local/bin/ss-* \
    | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
    | sort -u) \
    && cd \
    && rm -rf "shadowsocks-libev-${SHADOWSOCKS_LIBEV_VER}"

RUN addgroup --system --gid "$SSL_CERT_GID" ssl-cert
USER nobody:ssl-cert

CMD exec /usr/local/bin/ss-server -n 65535 -c /config/config.json -u $ARGS
