# dropboxd will use sync files to $HOME/Dropbox

FROM ubuntu:14.04
MAINTAINER menghan

RUN adduser --uid 1000 --group --system user

RUN apt-get update
RUN apt-get install -y wget
RUN wget -q -O - https://www.dropbox.com/download?plat=lnx.x86_64 | tar xzf -

USER user
ENV HOME /home/user
CMD /.dropbox-dist/dropboxd
