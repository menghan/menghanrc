FROM menghan/golang

MAINTAINER Menghan Zheng <menghan412@gmail.com>

RUN GOPATH=/usr/local /usr/local/bin/go get github.com/menghan/cow
ADD samplerc /rc

ENV LANG C.UTF-8

ENTRYPOINT ["/usr/local/bin/cow"]
CMD ["-h"]
