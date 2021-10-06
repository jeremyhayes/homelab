FROM golang:alpine

EXPOSE 8080
EXPOSE 8181

RUN go get github.com/google/martian/ && \
    go install github.com/google/martian/cmd/proxy@latest

ENTRYPOINT $GOPATH/bin/proxy -v=3 -generate-ca-cert=true
