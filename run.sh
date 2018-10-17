#!/usr/bin/env bash

if [[ -z "${INTERNAL_URL}" ]]; then
  echo "Please set the env var INTERNAL_URL to run this container"
  exit
else
  echo "Internal URL is ${INTERNAL_URL}"
fi

# Rewrite the url for ci.sh
if [ -f /usr/share/nginx/html/ci.sh ]; then
  sed -i.bck -e "s@https://download.sourceclear.com@$INTERNAL_URL@g" /usr/share/nginx/html/ci.sh
fi

nginx -g "daemon off;"
