FROM alpine:3.22.1 AS builder

RUN apk add --no-cache build-base go git

RUN git clone --branch v0.5.12 https://github.com/yggdrasil-network/yggdrasil-go.git /src
WORKDIR /src

RUN go build -ldflags '-s -w -extldflags '-static'' -o /yggdrasil ./cmd/yggdrasil 
RUN go build -ldflags '-s -w -extldflags '-static'' -o /yggdrasilctl ./cmd/yggdrasilctl

FROM alpine:3.22.1

RUN apk add --no-cache bash busybox bind-tools iproute2 iptables curl supervisor wget

RUN wget -qO- https://github.com/ginuerzh/gost/releases/download/v2.12.0/gost_2.12.0_linux_amd64.tar.gz \
	| tar -xz -C /usr/local/bin gost && \
	chmod +x /usr/local/bin/gost


COPY --from=builder /yggdrasil /usr/local/bin/yggdrasil
COPY --from=builder /yggdrasilctl /usr/local/bin/yggdrasilctl

COPY supervisord.conf /etc/supervisord.conf

VOLUME ["/etc/yggdrasil"]

EXPOSE 10880 10881

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

