#!/bin/bash
set -e

SESSION_ID=$(curl -X POST \
  -H 'content-type: application/json' \
  -H 'x-forwarded-for: 200.200.200.200' \
  --data '{ "environment": "pwr_server", "eventTime": "2020-10-10T10:10:10.000Z", "appVersion": "1.0" }' \
  --silent \
  http://localhost:10000/api/v1/analytics/appOpened | jq .sessionId)

echo "Got sessionId=${SESSION_ID}"

RESPONSE_CODE=$(curl -X POST \
  -H 'content-type: application/json' \
  -H 'x-forwarded-for: 200.200.200.200' \
  --silent \
  --w "%{response_code}" \
  --data "{ \"pageName\": \"home\", \"eventTime\": \"2020-10-10T10:10:11.000Z\", \"sessionId\": ${SESSION_ID} }" \
  http://localhost:10000/api/v1/analytics/pageOpened)

if [[ RESPONSE_CODE -eq 201 ]]; then
  echo "Success - pageOpened event was saved!"
else
  echo "Failure - server returned ${RESPONSE_CODE} status code."
fi
