FROM alpine:3.11 as build

RUN apk add curl && \
    curl -sfL https://install.goreleaser.com/github.com/goreleaser/goreleaser.sh | sh

FROM alpine:3.11 as runtime

COPY --from=build /bin/goreleaser /bin/goreleaser

ENTRYPOINT ["/bin/goreleaser"]