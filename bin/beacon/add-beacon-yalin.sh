#!/usr/bin/env bash

set -eo pipefail

airnode=0x9E1D2311c407AD0953f6BAa51209C014729D8343
sponsor=0x00000000007317c91F57D86A410934A490E62E1E
sponsorWallet=0x319dB0E57db30606C1c3cB585BeB13B3aA643488

. $(dirname $0)/add-beacon.sh $airnode $sponsor $sponsorWallet
