#!/usr/bin/env bash

OS=$1

if [[ ! -d vendor/oracle ]] \
  || [[ ! -f vendor/oracle/$OS/oic.zip ]] \
  || [[ ! -f vendor/oracle/$OS/osdk.zip ]] \
  || [[ ! -f vendor/oracle/$OS/osqlplus.zip ]]; then
    cat <<EOF

You are missing oracle instant client (light), sdk, and sqlplus from one of these urls

Darwin: https://www.oracle.com/database/technologies/instant-client/macos-intel-x86-downloads.html
Linux: https://www.oracle.com/database/technologies/instant-client/linux-x86-64-downloads.html

***VERSION 12.2.0.1.0 IS REQUIRED***

Download and put the instant client (light) zipfile at ./vendor/oracle/$OS/oic.zip
Download and put the sdk zipfile at ./vendor/oracle/$OS/osdk.zip
Download and put the sdk zipfile at ./vendor/oracle/$OS/osqlplus.zip

EOF
    exit 127
fi

cd "vendor/oracle/$OS" || exit 1

rm -rf instantclient_12_2

echo "-> Extracting Oracle Instant Client"
unzip oic.zip 1>/dev/null

echo "-> Extracting Oracle SDK"
unzip osdk.zip 1>/dev/null

echo "-> Extracting Oracle SqlPlus"
unzip osqlplus.zip 1>/dev/null

if [[ "$OS" == "Linux" ]]; then
  cd instantclient_12_2 || exit 1
  ln -s libclntsh.so.12.1 libclntsh.so
fi
