cd /workdir
rm build/conf/*
source sources/poky/oe-init-build-env
cat /usr/bin/bb/conf/local.conf >> conf/local.conf
cat /usr/bin/bb/conf/bblayers.conf >> conf/bblayers.conf
bitbake core-image-minimal
