#!/usr/bin/env bash

if type sq &>/dev/null && [[ `sq version 2>&1` == *sequoia-openpgp* ]]; then
  ARMOR="sq toolbox armor"
elif type sq &>/dev/null; then
  ARMOR="gpg --enarmor -o-"
else
  echo "$0: Can't find a PGP implimentation I know how to use!"
  exit 1
fi

if type curl &>/dev/null; then
  CURL="curl -fsL"
elif type curl &>/dev/null; then
  CURL="wget -q -O-"
else
  echo "$0: Can't find curl!"
  exit 1
fi

odie () {
  echo "FAIL: $1" >&2
  exit 1
}

get_key () {
  NAME=$1
  URL=$2

  echo "$0: Fetching ${URL}"
  ${CURL} "${URL}" > "${NAME}.download" || odie "Can't download key for ${NAME}!"
  ${ARMOR} "${NAME}.download" > "${NAME}.asc" || odie "Can't armor key for ${NAME}!"
  rm "${NAME}.download"
}

# All output files will automatically get a ".asc" extension, just specify the
# basename here.
get_key 'adoptium'     'https://packages.adoptium.net/artifactory/api/gpg/key/public'
get_key 'docker'       'https://download.docker.com/linux/debian/gpg'
get_key 'elastic.co'   'https://artifacts.elastic.co/GPG-KEY-elasticsearch'
get_key 'grafana'      'https://apt.grafana.com/gpg.key'
get_key 'hpe'          'https://downloads.linux.hpe.com/SDR/hpePublicKey2048_key1.pub'
get_key 'k8s.io'       'https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key'
get_key 'mono-project' 'https://download.mono-project.com/repo/xamarin.gpg'
get_key 'nodesource'   'https://deb.nodesource.com/gpgkey/nodesource.gpg.key'
get_key 'php-community-sury.org' \
                       'https://packages.sury.org/php/apt.gpg'
get_key 'puppetlabs'   'https://apt.puppetlabs.com/keyring.gpg'
get_key 'tesseract-notesalexp.org' \
                       'https://notesalexp.org/debian/alexp_key.asc'
get_key 'yarnpkg'      'https://dl.yarnpkg.com/debian/pubkey.gpg'
get_key 'yaz-indexdata.dk' \
                       'https://download.indexdata.com/debian/indexdata.gpg'
