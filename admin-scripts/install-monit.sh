#!/usr/bin/env bash

. install-common.sh

# TODO: depend flex ssl
MONITSRC="http://mmonit.com/monit/dist/monit-5.0.3.tar.gz"
SOFTSRC=$MONITSRC
TARFILE=${SOFTSRC##*\/}
DIRNAME=${TARFILE%.tar.gz}

rm -rf $TARFILE ${DIRNAME}
download_or_exit $SOFTSRC
tar xf $TARFILE && cd ${DIRNAME}
patch -p1 < ../patchs/${DIRNAME}.patch
./configure --prefix=${INSTALLPREFIX} && make && sudo make install
if ! test -e ${INSTALLPREFIX}/etc; then
	sudo ln -s /etc ${INSTALLPREFIX}/
fi
if ! test -e /usr/local/bin/monit; then
	sudo ln -s ${INSTALLPREFIX}/bin/monit /usr/local/bin/monit
fi
sudo cp monitrc /etc
sudo cp contrib/rc.monit /etc/init.d/monit
sudo chmod +x /etc/init.d/monit
sudo /etc/init.d/monit restart
sudo /sbin/chkconfig --add monit
# rm -rf ${DIRNAME}
