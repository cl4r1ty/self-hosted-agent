#!/usr/bin/env sh

#
#  Copyright (c) 2018 SourceClear Inc
#

# For more verbose output, run with 'DEBUG=1 path/to/ci.sh'

TONGINX_DIR=${TONGINX_DIR:-./tonginx}
DEBUG=${DEBUG:-0}

main() {
  debug_runtime_options
  check_binaries
  create_temp_folder
  check_and_set_latest_version
  download_latest_version linux
  download_latest_version macosx
  download_latest_version windows zip
  download_ci_sh
}

debug() {
  [ ${DEBUG} -ge 1 ] && echo "debug: $@" >&2
}

debug_runtime_options() {
  debug 'DEBUG is enabled'
}

check_binaries() {
  local rc=0
  for binary in curl date uname gzip; do
    if which $binary > /dev/null; then
      debug "check_binaries: checking for $binary: OK"
    else
      echo "$binary is required to continue, but could not be found on your system." >&2
      rc=1
    fi
  done
  if [ $rc != 0 ]; then
    exit $rc
  fi
}

create_temp_folder() {
  rm -Rf tonginx
  mkdir -p tonginx/
  FOLDER="$(mktemp -q -d -t srcclr.XXXXXX 2>/dev/null || mktemp -q -d)"
  debug "create_temp_folder: Using $FOLDER as temporary folder."
  cleanup() {
    C=$?
    debug "create_temp_folder: cleanup: cleaning up \"$FOLDER\""
    rm -rf "$FOLDER"
    trap - EXIT
    exit $C
  }
  trap cleanup EXIT INT
}

check_and_set_latest_version() {
  debug "check_and_set_latest_version: checking latest version..."
  if curl -m30 -f -v -o "$FOLDER/version" https://download.sourceclear.com/LATEST_VERSION 2>"$FOLDER/curl-output"; then
    latest_version=$(cat "$FOLDER/version")
    debug "check_and_set_latest_version: retrieved LATEST_VERSION: $latest_version"
    debug "check_and_set_latest_version: latest version does not exist and will be downloaded."
    cp "$FOLDER/version" "${TONGINX_DIR}/LATEST_VERSION"
    return 1
  else
    debug "check_and_set_latest_version: retrieving LATEST_VERSION failed: $?"
    echo "warning: we were not able to retrieve LATEST_VERSION, and will therefore not used the locally cached agent" >&2
    echo "warning: curl provided the following output, which may be useful for debugging:" >&2
    cat "$FOLDER/curl-output" >&2
    latest_version="latest"
    return 1
  fi
}

download_latest_version() {
  OS=$1
  extension=${2:-tgz}
  local url="https://download.sourceclear.com/srcclr-${latest_version}-$OS.$extension"
  debug "download_latest_version: retrieving srcclr v${latest_version} for ${OS} via ${url}..."
  local t0=$(date +%s)
  if curl -m 300 -f -v -o "$FOLDER/srcclr-${latest_version}-${OS}.$extension" "${url}" 2>"$FOLDER/curl-output"; then
    debug "download_latest_version: retrieved ${OS} in $(( $(date +%s) - $t0 ))s."
    if [ ! -d "$TONGINX_DIR" ]; then
      mkdir "$TONGINX_DIR"
    fi
    mv "$FOLDER/srcclr-${latest_version}-${OS}.$extension" "${TONGINX_DIR}"
  else
    debug "download_latest_version: retrieval failed: $?"
    echo "We were not able to download your installation package from ${url}." >&2
    echo "Curl provided the following output, which may be useful for debugging:" >&2
    cat "$FOLDER/curl-output" >&2
    exit 1
  fi
}

download_ci_sh() {
  local url="https://download.sourceclear.com/ci.sh"
  debug "download_ci_sh: retrieving ci.sh via ${url}..."
  local t0=$(date +%s)
  if curl -m 300 -f -v -o "$FOLDER/ci.sh" "${url}" 2>"$FOLDER/curl-output"; then
    debug "download_ci_sh: retrieved ci.sh in $(( $(date +%s) - $t0 ))s."
    if [ ! -d "$TONGINX_DIR" ]; then
      mkdir "$TONGINX_DIR"
    fi
    mv "$FOLDER/ci.sh" "${TONGINX_DIR}"
  else
    debug "download_ci_sh: retrieval failed: $?"
    echo "We were not able to downloadci.sh from ${url}." >&2
    echo "Curl provided the following output, which may be useful for debugging:" >&2
    cat "$FOLDER/curl-output" >&2
    exit 1
  fi
}

main "$@"
