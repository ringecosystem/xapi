#!/usr/bin/env bash

set -eo pipefail

airnode=0x9E1D2311c407AD0953f6BAa51209C014729D8343
sponsor=0x000000000a0D8ac9cc6CbD817fA77090322FF29d
sponsorWallet=0x319dB0E57db30606C1c3cB585BeB13B3aA643488

. $(dirname $0)/add-beacon.sh $airnode $sponsor $sponsorWallet
