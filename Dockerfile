FROM alpine:3.12

RUN apk add --update coreutils jq bash curl

RUN ["chmod", "+x", "/entrypoint.sh"]

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]