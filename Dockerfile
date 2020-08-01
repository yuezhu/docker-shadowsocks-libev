FROM golang:alpine as builder

RUN \
    apk update \
    && apk add --no-cache git \
    && mkdir /build \
    && git clone https://github.com/shadowsocks/v2ray-plugin.git /build

WORKDIR /build

RUN go build -o v2ray-plugin_linux_amd64 .

FROM shadowsocks/shadowsocks-libev

ARG SSL_CERT_GID=115

VOLUME /config

ENV TZ=UTC
ENV ARGS=

COPY --from=builder /build/v2ray-plugin_linux_amd64 /usr/bin/v2ray-plugin

USER root

RUN \
    apk update \
    && apk add --no-cache --virtual .build-deps \
    libcap \
    && setcap cap_net_bind_service+ep /usr/bin/v2ray-plugin \
    && apk del .build-deps \
    && addgroup --system --gid "$SSL_CERT_GID" ssl-cert

USER nobody:ssl-cert

CMD exec /usr/bin/ss-server -n 65535 -c /config/config.json -u $ARGS
