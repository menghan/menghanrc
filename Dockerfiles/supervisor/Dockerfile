FROM debian:wheezy
MAINTAINER Menghan Zheng <menghan412@gmail.com>

RUN useradd --system --create-home --user-group user

RUN apt-get update && \
	apt-get install -y supervisor && \
	apt-get clean
RUN sed -i 's/chmod=0700/chmod=0770/g' /etc/supervisor/supervisord.conf
RUN sed -i 's%var/\+run%var/run/supervisor%g' /etc/supervisor/supervisord.conf
RUN mkdir -p /var/log/supervisor /var/run/supervisor && \
	    chgrp user /var/log/supervisor /var/run/supervisor && \
	    chmod g+w /var/log/supervisor /var/run/supervisor

VOLUME /var/log/supervisor/
VOLUME /var/run/supervisor/

CMD /usr/bin/supervisord -n
