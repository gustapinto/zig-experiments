FROM alpine:3.21.2

WORKDIR /zig-experiments

RUN apk add zig

ENTRYPOINT ["/bin/sh"]
