#!/usr/bin/env bash
# Creates a release build for web. 
# This script should be run in the root of flutter project.

set -e

DEPLOYMENT_ENDPOINT=$1

if [ -z "${DEPLOYMENT_ENDPOINT}" ]; then
  echo "Please provide a deployment endpoint as the first argument."
  exit 1
fi


flutter pub get

# It looks like cleaning is mandatory, otherwise the generated file will not change
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs

flutter test

flutter build web --web-renderer=html --base-href "${DEPLOYMENT_ENDPOINT}"
