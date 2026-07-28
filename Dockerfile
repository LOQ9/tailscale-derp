# syntax=docker/dockerfile:1

ARG TAILSCALE_VERSION=v1.98.9
ARG GO_VERSION=1.23-alpine

FROM golang:${GO_VERSION} AS builder
ARG TAILSCALE_VERSION
RUN apk add --no-cache git ca-certificates
ENV CGO_ENABLED=0
RUN go install "tailscale.com/cmd/derper@${TAILSCALE_VERSION}"

FROM alpine:3.20 AS runtime
RUN apk add --no-cache ca-certificates && \
    addgroup -S derper && adduser -S derper -G derper
COPY --from=builder /go/bin/derper /usr/local/bin/derper
USER derper
EXPOSE 443/tcp
EXPOSE 8080/tcp
EXPOSE 3478/udp
ENTRYPOINT ["/usr/local/bin/derper"]
CMD ["--a=:443", "--http-port=8080", "--stun=true"]
