#!/usr/bin/env bash

if [[ ! -f vendor/oracle/oic.zip ]] || [[ ! -f vendor/oracle/osdk.zip ]] || [[ ! -f vendor/oracle/osqlplus.zip ]] || [[ ! -d vendor/oracle ]]; then
  echo
  echo "You must download the oracle instant client (light) and sdk from one of these urls"
  echo "***VERSION 12.2.0.1.0 IS REQUIRED***"
  echo
  echo "macOS: https://www.oracle.com/database/technologies/instant-client/macos-intel-x86-downloads.html"
  echo "Linux: https://www.oracle.com/database/technologies/instant-client/linux-x86-64-downloads.html"
  echo
  echo "Download and put the instant client zipfile at ./vendor/oracle/oic.zip"
  echo "Download and put the sdk zipfile at ./vendor/oracle/osdk.zip"
  echo
  exit 127
fi

cd vendor/oracle || exit 1

rm -rf instantclient_12_2

echo "-> Extracting Oracle Instant Client"
unzip oic.zip 1>/dev/null

echo "-> Extracting Oracle SDK"
unzip osdk.zip 1>/dev/null

echo "-> Extracting Oracle SqlPlus"
unzip osqlplus.zip 1>/dev/null

cd ../../ || exit 1
