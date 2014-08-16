# dropboxd will use sync files to $HOME/Dropbox

FROM debian:wheezy
MAINTAINER Menghan Zheng <menghan412@gmail.com>

RUN apt-get update && apt-get install -y wget && \
	wget -qO - https://www.dropbox.com/download?plat=lnx.x86_64 | tar -C / -xz && \
	apt-get purge -y wget && apt-get autoremove -y && apt-get clean

RUN useradd --uid 1000 --system --create-home --user-group user
USER user
ENV HOME /home/user
CMD /.dropbox-dist/dropboxd
