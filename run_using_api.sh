#!/bin/bash

while getopts k: flag
do
    case "${flag}" in
        k) PACE_API_KEY=${OPTARG};;
    esac
done

if test -z "$PACE_API_KEY" 
then
    echo "\$PACE_API_KEY is empty! Exiting."
    exit 1
fi
PACE_API_URL=https://eu-robotic.copado.com/pace/v4/builds

# Start the build
BUILD=$(curl -sS -d '{"key": "'${PACE_API_KEY}'", "inputParameters": [{"key": "BROWSER", "value": "firefox"}]}' -H "Content-Type: application/json" -X POST ${PACE_API_URL})
echo "${BUILD}"
BUILD_ID=$(echo "${BUILD}" | grep -o '"id":\K[0-9]+')
if [ -z "${BUILD_ID}" ]; then
    exit 1
fi

echo -n "Executing tests "

# Poll every 10 seconds until the build is finished
STATUS='"executing"'
while [ "${STATUS}" == '"executing"' ]; do
    sleep 10
    RESULTS=$(curl -sS ${PACE_API_URL}/${BUILD_ID}?key=${PACE_API_KEY})
    STATUS=$(echo "${RESULTS}" | grep -o '"status": *\K"[^"]*"' | head -1)
    echo -n "."
done

echo " Done!"

FAILURES=$(echo ${RESULTS} | grep -Po '"failures":\K[0-9]+')
LOG_REPORT_URL=$(echo "${RESULTS}" | grep -Po '"logReportUrl": *\K"[^"]*"')

echo "Report URL: ${LOG_REPORT_URL}"
