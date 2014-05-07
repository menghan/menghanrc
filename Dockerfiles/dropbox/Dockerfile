# dropboxd will use sync files to $HOME/Dropbox

FROM ubuntu:14.04
MAINTAINER menghan

RUN adduser --uid 1000 --group --system dropboxer

ADD install-dropbox.sh /usr/local/bin/
RUN install-dropbox.sh

USER dropboxer
ENV HOME /home/dropboxer
CMD /.dropbox-dist/dropboxd
