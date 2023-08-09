#!/bin/sh -e

usage_exit() {
  cat 1>&2 <<EOS
usage: $0 suffix0 suffix1

example:
  $0 before-mining after-mining
EOS
  exit $1
}

suffix0="$1"
suffix1="$2"
[ -z "$suffix0" ] && usage_exit 1
[ -z "$suffix1" ] && usage_exit 1

logfilename0=$(ls -1 log-????????T??????-"$suffix0".txt | tail -1)
logfilename1=$(ls -1 log-????????T??????-"$suffix1".txt | tail -1)
[ -z "$logfilename0" ] && exit 1
[ -z "$logfilename1" ] && exit 1

diff -u "$logfilename0" "$logfilename1" || true
