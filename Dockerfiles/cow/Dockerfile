FROM menghan/golang

MAINTAINER Menghan Zheng <menghan412@gmail.com>

RUN GOPATH=/usr/local /usr/local/bin/go get github.com/menghan/cow
ADD samplerc /rc

VOLUME /var/tmp/.cow
RUN chown nobody:nogroup /var/tmp/.cow
ENV HOME /var/tmp
USER nobody

ENTRYPOINT ["/usr/local/bin/cow"]
CMD ["-h"]
