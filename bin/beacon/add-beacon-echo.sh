#!/usr/bin/env bash

set -eo pipefail

airnode=0xC8124108C02155b018F6C0EBdB9cb569880BDFf3
sponsor=0x00000000007317c91F57D86A410934A490E62E1E
sponsorWallet=0xfD1b46c1a84134f64401d8eAe851e39D4f472A3C

. $(dirname $0)/add-beacon.sh $airnode $sponsor $sponsorWallet
