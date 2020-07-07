FROM shadowsocks/shadowsocks-libev

ARG V2RAY_PLUGIN_VER=1.3.1
ARG SSL_CERT_GID=115

VOLUME /config

ENV TZ=UTC
ENV ARGS=

USER root
WORKDIR /root/

RUN \
    apk update && \
    apk add --no-cache --virtual .build-deps \
    libcap \
    wget \
    gzip \
    tar \
    && wget -O- "https://github.com/shadowsocks/v2ray-plugin/releases/download/v${V2RAY_PLUGIN_VER}/v2ray-plugin-linux-amd64-v${V2RAY_PLUGIN_VER}.tar.gz" | tar xvzf - \
    && mv v2ray-plugin_linux_amd64 /usr/bin/v2ray-plugin \
    && setcap cap_net_bind_service+ep /usr/bin/v2ray-plugin \
    && apk del .build-deps \
    && rm -rf v2ray-plugin-linux-amd64-v${V2RAY_PLUGIN_VER}

RUN addgroup --system --gid "$SSL_CERT_GID" ssl-cert

USER nobody:ssl-cert

CMD exec /usr/bin/ss-server -n 65535 -c /config/config.json -u $ARGS
