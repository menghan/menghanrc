FROM menghan/base

MAINTAINER Menghan Zheng <menghan412@gmail.com>

RUN apt-get update && \
	    apt-get install -y s3cmd python-setuptools python-lockfile python-dev librsync-dev ncftp python-boto gnupg wget ca-certificates && \
	    wget -q -O /usr/local/bin/duplicity-backup.sh https://raw.githubusercontent.com/zertrin/duplicity-backup/master/duplicity-backup.sh && \
	    wget -qO - "http://code.launchpad.net/duplicity/0.6-series/0.6.25/+download/duplicity-0.6.25.tar.gz" | tar -xz -f - -C /tmp && \
	    cd /tmp/duplicity-0.6.25 && \
	    python setup.py install && \
	    apt-get purge -y python-dev librsync-dev librsync1+ wget ca-certificates && \
	    apt-get autoremove -y && \
	    rm -rf /var/lib/apt/lists/* /tmp/duplicity-0.6.25
