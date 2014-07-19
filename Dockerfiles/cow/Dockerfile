from ubuntu:14.04

maintainer menghan <menghan412@gmail.com>

ADD http://golang.org/dl/go1.3.linux-amd64.tar.gz /usr/local/
RUN apt-get install --no-install-recommends -y mercurial
RUN GOPATH=/usr/local /usr/local/go/bin/go get github.com/menghan/cow

CMD cow -rc /rc
