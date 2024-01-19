!#/bin/bash

set -e

USERNAME=$1
HOST=$2
PATH=$3

rsync -av --delete build/web/ ${USERNAME}@${HOST}:${PATH}
