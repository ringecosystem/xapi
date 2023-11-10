#!/usr/bin/env bash

set -eo pipefail

airnode=0xC8124108C02155b018F6C0EBdB9cb569880BDFf3
sponsor=0x000000000a0D8ac9cc6CbD817fA77090322FF29d
sponsorWallet=0xfD1b46c1a84134f64401d8eAe851e39D4f472A3C

. $(dirname $0)/add-beacon.sh $airnode $sponsor $sponsorWallet
