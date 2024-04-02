set -e

GIT_VERSION=$(git describe --tags --abbrev=0)
PURE_VERSION=$(echo "$GIT_VERSION" | cut -d '/' -f 2)
echo "Current version is $PURE_VERSION"

./gradlew -Pversion="$PURE_VERSION" jib
