#!/bin/bash
# Build tarsnap RPM
VERSION="$(cat /vagrant/CURRENT_TARSNAP_VERSION)"
OS_NAME="$(lsb_release --id --short)-$(lsb_release --release --short)"
TEMPDIR="$(mktemp -d)"
ORIG_DIR="$PWD"
cd "$TEMPDIR"

wget https://www.tarsnap.com/download/tarsnap-autoconf-$VERSION.tgz
tar -xzvf tarsnap-autoconf-$VERSION.tgz 
cd tarsnap-autoconf-$VERSION
./configure 
make all
INSTALL_TEMPDIR="$(mktemp -d)"
mkdir "$INSTALL_TEMPDIR"
make install DESTDIR="$INSTALL_TEMPDIR"
fpm -s dir -t rpm -n tarsnap -v $VERSION -C "$INSTALL_TEMPDIR" -p tarsnap-VERSION_${OS_NAME}_ARCH.rpm --config-files usr/local/etc/tarsnap.conf --architecture native --vendor 'Colin Percival' --url 'https://www.tarsnap.com/' usr/local
PACKAGE_NAME=$(ls -1 *.rpm)
PACKAGE_PATH="${PWD}/${PACKAGE_NAME}"
echo "Package built: $PACKAGE_PATH"

# Do some rudimentary testing
sudo yum remove -y tarsnap > /dev/null 2>&1
rpm --checksig "$PACKAGE_PATH" || exit 1
sudo yum install --nogpgcheck -y "$PACKAGE_PATH" || exit 1 && echo "yum install of tarsnap successful"

mkdir -p /vagrant/packages
cp -f "$PACKAGE_PATH" /vagrant/packages/

cd $ORIG_DIR
