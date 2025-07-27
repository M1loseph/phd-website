#!/bin/bash

set -e

ARG_USERNAME=$1
ARG_HOST=$2
ARG_PATH=$3

rsync --verbose --timeout=20 -av --delete build/web/ ${ARG_USERNAME}@${ARG_HOST}:${ARG_PATH}
