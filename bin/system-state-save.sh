#!/bin/sh -e

usage_exit() {
  cat 1>&2 <<EOS
usage: $0 suffix

examples:
  $0 after-btcd-modded
  $0 before-mining
EOS
  exit $1
}

suffix="$1"
[ -z "$suffix" ] && usage_exit 1

GOPATH=$(go env GOPATH)
BTCCTL="$GOPATH/bin/btcctl"
BTCCTL_OPTIONS="--simnet --rpcuser=hoge --rpcpass=hoge"
logfilename=$(date +log-%Y%m%dT%H%M%S-"$suffix".txt)

(
    echo "@@@ list accounts"
    "$BTCCTL" $BTCCTL_OPTIONS listaccounts || true

    "$BTCCTL" $BTCCTL_OPTIONS listaccounts | grep '"' | sed -e 's/^ *"//' -e 's/".*$//' | while read name; do
        echo "@@@ get balance $name"
        "$BTCCTL" getbalance "$name" || true
    done

    echo
    echo "@@@ get current net"
    "$BTCCTL" $BTCCTL_OPTIONS getcurrentnet || true

    echo
    echo "@@@ get connection count"
    "$BTCCTL" $BTCCTL_OPTIONS getconnectioncount || true

    echo
    echo "@@@ get peer info"
    "$BTCCTL" $BTCCTL_OPTIONS getpeerinfo || true

    echo
    echo "@@@ get blockchain info"
    "$BTCCTL" $BTCCTL_OPTIONS getblockchaininfo || true
) 2>&1 | tee "$logfilename"

echo "$0: status saved to '$logfilename'" 1>&2
