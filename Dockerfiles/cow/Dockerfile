from ubuntu:14.04

maintainer menghan <menghan412@gmail.com>

RUN apt-get update
RUN apt-get install -y mercurial git supervisor

ADD http://golang.org/dl/go1.3.linux-amd64.tar.gz /usr/local/

RUN GOPATH=/usr/local /usr/local/go/bin/go get github.com/menghan/cow
ADD cow.conf /etc/supervisor/conf.d/

VOLUME /var/log/supervisor
CMD /usr/bin/supervisord -n
