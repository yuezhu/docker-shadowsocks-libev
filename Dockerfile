FROM golang:alpine as builder

RUN \
    apk update \
    && apk add --no-cache git \
    && mkdir /build \
    && git clone https://github.com/shadowsocks/v2ray-plugin.git /build \
    && cd /build \
    && go build -o v2ray-plugin

FROM shadowsocks/shadowsocks-libev:edge

ARG SSL_CERT_GID=115

ENV TZ=UTC
ENV ARGS=

COPY --from=builder /build/v2ray-plugin /usr/bin/v2ray-plugin

USER root

RUN \
    apk update \
    && apk add --no-cache --virtual .build-deps \
    libcap \
    && setcap cap_net_bind_service+ep /usr/bin/v2ray-plugin \
    && apk del .build-deps \
    && addgroup --system --gid "$SSL_CERT_GID" ssl-cert

USER nobody:ssl-cert

CMD exec /usr/bin/ss-server \
    -n 65535 \
    -c /config.json \
    -u $ARGS
