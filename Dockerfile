FROM golang:latest

ONBUILD ARG VERSION_PREFIX="release-"
ONBUILD ARG VERSION

RUN apt install git dep build-essential linux-headers

COPY ./gen.go /code/gen.go

RUN set -x && \
    git clone --depth 1 https://github.com/influxdata/telegraf.git /go/src/github.com/influxdata/telegraf && \
    cd /go/src/github.com/influxdata/telegraf && \
    make build && \
    cp telegraf /etc/telegraf && \
    mkdir -p /go/src/github.com/influxdata/telegraf/gen && \
    cp /code/gen.go /go/src/github.com/influxdata/telegraf/gen/gen.go && \
    go run ./gen/gen.go && \
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build ./cmd/telegraf

ENTRYPOINT [ "/bin/bash" ]