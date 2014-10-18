# dropbox will sync files to $HOME/Dropbox

FROM debian:latest
MAINTAINER Menghan Zheng <menghan412@gmail.com>

RUN apt-get update && apt-get install -y wget && \
	wget --no-check-certificate -qO - https://www.dropbox.com/download?plat=lnx.x86_64 | tar -xz -C / -f - && \
	apt-get purge -y wget && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*
