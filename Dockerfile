FROM golang:latest

COPY ./gen.go /code/gen.go

RUN set -x && \
    apt-get update && \
    apt-get install -y --no-install-recommends git build-essential && \
    git clone --depth 1 https://github.com/influxdata/telegraf.git /go/src/github.com/influxdata/telegraf && \
    cd /go/src/github.com/influxdata/telegraf && \
    make build && \
    cp telegraf /etc/telegraf && \
    mkdir -p /go/src/github.com/influxdata/telegraf/gen && \
    cp /code/gen.go /go/src/github.com/influxdata/telegraf/gen/gen.go && \
    go run ./gen/gen.go && \
    CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build ./cmd/telegraf
