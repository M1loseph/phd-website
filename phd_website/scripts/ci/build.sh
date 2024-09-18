#!/usr/bin/env bash
# Creates a release build for web. 
# This script should be run in the root of flutter project.

set -e

DEPLOYMENT_ENDPOINT=$1
ANALYTICS_SERVER_URL=$2
ENVIRONMENT=$3

if [ -z "${DEPLOYMENT_ENDPOINT}" ]; then
  echo "Please provide a deployment endpoint as the first argument."
  exit 1
fi

if [ -z "${ANALYTICS_SERVER_URL}" ]; then
  echo "Please provide an analytics sever url (including http/https ) as the second argument."
  exit 1
fi

if [ -z "${ENVIRONMENT}" ]; then
  echo "Please provide an analytics sever url (including http/https ) as the second argument."
  exit 1
fi


flutter pub get

# It looks like cleaning is mandatory, otherwise the generated file will not change
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs

flutter test

# Fix for icons caching issue
# https://github.com/flutter/flutter/issues/136585#issuecomment-2354612183
flutter build web --base-href "${DEPLOYMENT_ENDPOINT}" \
    --dart-define ANALYTICS_SERVER_URL="${ANALYTICS_SERVER_URL}" \
    --dart-define ENVIRONMENT="${ENVIRONMENT}" \
    --no-tree-shake-icons
