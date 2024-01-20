set -e

PORT=${1-:3000}
echo "I will start a server on port $PORT"
python -m http.server -d build/web $PORT
