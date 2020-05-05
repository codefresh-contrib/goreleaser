ARG GOLANG_VERSION=1.13

FROM alpine:3.11 as build

RUN apk add curl wget 

ARG GORELEASER_VERSION=0.118.1

RUN curl -L https://github.com/goreleaser/goreleaser/releases/download/v${GORELEASER_VERSION}/goreleaser_Linux_x86_64.tar.gz | tar xz -C /bin/ 

ARG CF_CLI_VERSION=v0.35.0

RUN wget https://github.com/codefresh-io/cli/releases/download/v0.35.0/codefresh-${CF_CLI_VERSION}-alpine-x64.tar.gz -O - \
  | tar -xzf - -C /bin 

FROM golang:${GOLANG_VERSION}-alpine3.11 as runtime

WORKDIR /step

RUN apk add --no-cache bash go git jq libgcc libstdc++

COPY --from=build /bin/codefresh /bin/codefresh
COPY --from=build /bin/goreleaser /bin/goreleaser

COPY entrypoint.sh .

ENTRYPOINT ["/bin/sh", "/step/entrypoint.sh"]

CMD ["goreleaser"]