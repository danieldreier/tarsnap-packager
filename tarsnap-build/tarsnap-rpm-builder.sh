#!/bin/bash
# Build tarsnap RPM
VERSION="1.0.35"
OS_NAME="$(lsb_release --id --short)-$(lsb_release --release --short)"
TEMPDIR="$(mktemp --directory)"
ORIG_DIR="$PWD"
cd "$TEMPDIR"

wget https://www.tarsnap.com/download/tarsnap-autoconf-$VERSION.tgz
tar -xzvf tarsnap-autoconf-$VERSION.tgz 
cd tarsnap-autoconf-$VERSION
./configure 
make all
mkdir /tmp/installdir
make install DESTDIR=/tmp/installdir
fpm -s dir -t rpm -n tarsnap -v 1.0.35 -C /tmp/installdir -p tarsnap-VERSION_${OS_NAME}_ARCH.rpm --config-files usr/local/etc/tarsnap.conf --architecture native --vendor 'Colin Percival' --url 'https://www.tarsnap.com/' usr/local
PACKAGE_NAME=$(ls -1 *.rpm)
PACKAGE_PATH="${PWD}/${PACKAGE_NAME}"
echo "Package built: $PACKAGE_PATH"
cp -f "$PACKAGE_PATH" /vagrant/packages/

cd $ORIG_DIR
