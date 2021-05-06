#!/bin/bash

# Overview: 
#
# Mount AWS S3 using s3fs, use debmirror to create an apt mirror in it.
#
# You can pass additional parameters to this script to apply them to 
# debmirror such as --dry-run, --verbose, etc.

# HOME is set as debmirror fails without it.
HOME=/var/local/apt-mirror

BUCKET_NAME=lit-ae-apt-mirror
BUCKET_MOUNT=${HOME}/apt-mirror

mkdir -p ${BUCKET_MOUNT}
s3fs ${BUCKET_NAME} ${BUCKET_MOUNT} -o iam_role=auto

# Import debian keys into file (trustedkeys.gpg) that debmirror recognizes
gpg --no-default-keyring --keyring trustedkeys.gpg --import /usr/share/keyrings/debian-archive-keyring.gpg

## Setting params for debmirror ##

HOST=ftp.us.debian.org;
DEST=${BUCKET_MOUNT}/debian

# Note: Removing a distro or architecture from these parameters will also
# remove them from the mirror because of how debmirror works.
DIST=stretch,buster,stretch-updates,buster-updates,stretch-backports,buster-backports
ARCH=amd64

# rsync is the recommended standard for synchronizing repos.
METHOD=rsync

# log start and end timestamp
logger -t apt-mirror[$$] updating Debian Apt mirror

debmirror ${DEST} \
 --nosource \
 --host=${HOST} \
 --root=/debian \
 --dist=${DIST} \
 --section=main,contrib,non-free,main/debian-installer \
 --i18n \
 --arch=${ARCH} \
 --method=${METHOD} \
 --passive --cleanup \
 --getcontents \
 "$@"

logger -t apt-mirror[$$] finished updating Debian Apt mirror

# unmount S3 to ensure integrity 
fusermount -u ${BUCKET_MOUNT}
