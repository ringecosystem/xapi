#!/usr/bin/env bash

set -eo pipefail

airnode=0xC8124108C02155b018F6C0EBdB9cb569880BDFf3
sponsor=0xC8124108C02155b018F6C0EBdB9cb569880BDFf3
sponsorWallet=0xAf63C2102c694BfAbFCf33eec9B21f4a828bBbA5

. $(dirname $0)/beacon/add-beacon.sh $airnode $sponsor $sponsorWallet
