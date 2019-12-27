ARG GOLANG_VERSION=1.13

FROM alpine:3.11 as build

RUN apk add curl wget 

RUN curl -sfL https://install.goreleaser.com/github.com/goreleaser/goreleaser.sh | sh 

ARG CF_CLI_VERSION=v0.35.0

RUN wget https://github.com/codefresh-io/cli/releases/download/v0.35.0/codefresh-${CF_CLI_VERSION}-alpine-x64.tar.gz -O - \
  | tar -xzf - -C /bin 

FROM golang:${GOLANG_VERSION}-alpine3.11 as runtime

WORKDIR /step

RUN apk add --no-cache go git jq libgcc libstdc++

COPY --from=build /bin/codefresh /bin/codefresh
COPY --from=build /bin/goreleaser /bin/goreleaser

COPY entrypoint.sh .

ENTRYPOINT ["/bin/sh", "/step/entrypoint.sh"]

CMD ["goreleaser"]