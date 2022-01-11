FROM alpine:latest
RUN apk add markdown curl jq libxml2-utils
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT /entrypoint.sh
