FROM golang:latest
MAINTAINER Menghan Zheng <menghan412@gmail.com>

ENV LANG C.UTF-8

RUN GOPATH=/usr/local go get github.com/menghan/cow
ADD samplerc /rc

RUN mkdir -p /var/tmp/.cow && chown nobody:nogroup /var/tmp/.cow
VOLUME /var/tmp/.cow

USER nobody
ENV HOME /var/tmp

ENTRYPOINT ["/usr/local/bin/cow"]
CMD ["-h"]
