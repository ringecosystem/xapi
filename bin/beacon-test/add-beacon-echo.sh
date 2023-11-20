#!/usr/bin/env bash

set -eo pipefail

airnode=0xC8124108C02155b018F6C0EBdB9cb569880BDFf3
sponsor=0x9F33a4809aA708d7a399fedBa514e0A0d15EfA85
sponsorWallet=0x6D58244F839CC6a5d71c0D6BcCCCf99FE5AE2966

. $(dirname $0)/add-beacon.sh $airnode $sponsor $sponsorWallet
