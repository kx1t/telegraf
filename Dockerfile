FROM golang:latest

ARG TARGETARCH
ARG TARGETOS

COPY ./gen.go /code/gen.go

RUN set -x && \
    echo "TARGETOS/TARGETARCH=${TARGETOS}/${TARGETARCH}" && \
    apt-get update && \
    apt-get install -y --no-install-recommends git build-essential && \
    git clone --depth 1 https://github.com/influxdata/telegraf.git /go/src/github.com/influxdata/telegraf && \
    cd /go/src/github.com/influxdata/telegraf && \
    make build && \
    cp telegraf /etc/telegraf && \
    mkdir -p /go/src/github.com/influxdata/telegraf/gen && \
    cp /code/gen.go /go/src/github.com/influxdata/telegraf/gen/gen.go

# we'll put this in a separate layer for now because if it fails, we don't have to download 
# everything again:
RUN set -x && \
    cd /go/src/github.com/influxdata/telegraf && \
    go run ./gen/gen.go

 RUN set -x && \   
    echo "TARGETOS/TARGETARCH=${TARGETOS}/${TARGETARCH}" && \
    cd /go/src/github.com/influxdata/telegraf && \
    CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build ./cmd/telegraf
