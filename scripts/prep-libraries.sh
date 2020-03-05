#!/usr/bin/env bash

echo "-> Downloading and extracting libaio"
mkdir -p vendor/lib/staging
cd vendor/lib/staging || exit 1

wget -q https://ftp5.gwdg.de/pub/linux/archlinux/core/os/x86_64/libaio-0.3.112-2-x86_64.pkg.tar.xz
tar xf libaio-0.3.112-2-x86_64.pkg.tar.xz > /dev/null
cd ..
mv staging/usr/lib/* ./
rm -rf staging

echo "-> Extracting oracle instantclient_12_2"
cp -r ../oracle/Linux/instantclient_12_2/* ./
