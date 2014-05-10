# dropboxd will use sync files to $HOME/Dropbox

FROM ubuntu:14.04
MAINTAINER menghan

RUN adduser --uid 1000 --group --system user

ADD install-dropbox.sh /usr/local/bin/
RUN install-dropbox.sh

USER user
ENV HOME /home/user
CMD /.dropbox-dist/dropboxd
