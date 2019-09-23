FROM golang:1.13.0-alpine AS build-env
ARG ENCRYPTIONKEY

WORKDIR /usr/local/go/src/github.com/facundomedica/encrypted-binary
COPY . /usr/local/go/src/github.com/facundomedica/encrypted-binary
RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh
RUN apk add --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main libressl=2.9.2-r0

RUN go build -o build/mybinary ./
RUN openssl enc -aes-256-cbc -pbkdf2 -iter 30000 -in build/mybinary -out build/mybinary.enc -k $ENCRYPTIONKEY

FROM alpine:latest
RUN apk add --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main libressl=2.9.2-r0
RUN apk add --no-cache curl ca-certificates tzdata && rm -rf /var/cache/apk/*
COPY --from=build-env /usr/local/go/src/github.com/facundomedica/encrypted-binary/build/mybinary.enc /bin/mybinary.enc
COPY --from=build-env /usr/local/go/src/github.com/facundomedica/encrypted-binary/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["mybinary"]

