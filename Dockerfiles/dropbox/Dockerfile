# dropbox will sync files to $HOME/Dropbox

FROM menghan/base
MAINTAINER Menghan Zheng <menghan412@gmail.com>

RUN apt-get update && apt-get install -y wget && \
	wget -qO - https://www.dropbox.com/download?plat=lnx.x86_64 | tar -C / -xz && \
	apt-get purge -y wget && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*
