#!/bin/bash
set -euo pipefail

PORT="${2}"
INSTANCE_CONNECTION_NAME="${3}"
TOKEN="${4:-null}"
IMPLICIT_CREDENTIALS="${GOOGLE_APPLICATION_CREDENTIALS:-null}"
DIR="/tmp/action-google-cloud-sql-proxy"
IMAGE="gcr.io/cloud-sql-connectors/cloud-sql-proxy:${1}"

if [ $IMPLICIT_CREDENTIALS != "null" ]; then
  echo "Starting proxy using GOOGLE_APPLICATION_CREDENTIALS"
  docker run \
    --detach \
    --restart on-failure \
    --name cloud-sql-proxy \
    --publish "127.0.0.1:${PORT}:${PORT}" \
    --volume "${IMPLICIT_CREDENTIALS}:${IMPLICIT_CREDENTIALS}" \
    "${IMAGE}" \
    ${INSTANCE_CONNECTION_NAME} \
    --address 0.0.0.0 \
    --credentials-file "${IMPLICIT_CREDENTIALS}"
elif [ $TOKEN = "null" ]; then
  echo "Starting proxy using credentials file"
  docker run \
    --detach \
    --restart on-failure \
    --name cloud-sql-proxy \
    --publish "127.0.0.1:${PORT}:${PORT}" \
    --volume "${DIR}:${DIR}" \
    "${IMAGE}" \
    ${INSTANCE_CONNECTION_NAME} \
    --address 0.0.0.0 \
    --credentials-file "${DIR}/key.json"
else
  echo "Starting proxy using token"
  docker run \
    --detach \
    --restart on-failure \
    --name cloud-sql-proxy \
    --publish "127.0.0.1:${PORT}:${PORT}" \
    "${IMAGE}" \
    ${INSTANCE_CONNECTION_NAME} \
    --address 0.0.0.0 \
    --token "${TOKEN}"
fi
