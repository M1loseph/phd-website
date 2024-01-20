#!/usr/bin/env bash
# Creates a release build for web. 
# This script should be run in the root of flutter project.

set -e

# / is the default deployment endpoint
DEPLOYMENT_ENDPOINT=${1:-/}


flutter pub get

# It looks like cleaning is mandatory, otherwise the generated file will not change
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs

flutter test

flutter build web --base-href "${DEPLOYMENT_ENDPOINT}"
