.PHONY: build push

TAG := latest

build:
	docker build -t yuezhu/shadowsocks-libev:$(TAG) .

push:
	docker push yuezhu/shadowsocks-libev:$(TAG)
