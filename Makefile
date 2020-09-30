.PHONY: build push

TAG := latest

build:
	docker pull shadowsocks/shadowsocks-libev:edge
	docker build -t yuezhu/shadowsocks-libev:$(TAG) .

push:
	docker push yuezhu/shadowsocks-libev:$(TAG)
