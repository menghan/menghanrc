FROM debian:latest

MAINTAINER Menghan Zheng <menghan412@gmail.com>

RUN apt-get update -yqq
RUN apt-get install -y git mercurial build-essential make wget

RUN wget -q -O - https://storage.googleapis.com/golang/go1.3.1.linux-amd64.tar.gz | tar -xz -C /usr/local

RUN ln -s /usr/local/go/bin/go /usr/local/bin/go
RUN ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt
RUN ln -s /usr/local/go/bin/godoc /usr/local/bin/godoc

RUN GOPATH=/usr/local /usr/local/bin/go get github.com/golang/lint/golint
RUN GOPATH=/usr/local /usr/local/bin/go get github.com/tools/godep
RUN GOPATH=/usr/local /usr/local/bin/go get github.com/jstemmer/gotags
RUN GOPATH=/usr/local /usr/local/bin/go get code.google.com/p/go.tools/cmd/vet

VOLUME ["/data"]
WORKDIR /data
ENV GOPATH /data

CMD ["go", "help"]
