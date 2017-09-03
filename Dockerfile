FROM golang:1.8-alpine as build-env
RUN apk add --no-cache git build-base && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk add --no-cache upx
ADD . /go/src/gitlab.com/klud/graphql-docker-api/
WORKDIR /go/src/gitlab.com/klud/graphql-docker-api/cmd/gql-dkr
RUN go get ./ && \
    CGO_ENABLED=0 GOOS=linux go build -a -ldflags="-s -w" -installsuffix cgo && \
#   upx --best -qq gql-dkr && \
    upx --ultra-brute -qq gql-dkr && \
    upx -t gql-dkr

FROM scratch
LABEL maintainer "Pierre Ugaz <pierre.ugaz@ruway.me>"
ENV API_ENDPOINT="" \
    DOCKER_CERT_PATH="" \
    DOCKER_HOST="" \
    GQL_PORT=""
COPY --from=build-env /go/src/gitlab.com/klud/graphql-docker-api/cmd/gql-dkr/gql-dkr .
EXPOSE 8080
CMD ["/gql-dkr"]