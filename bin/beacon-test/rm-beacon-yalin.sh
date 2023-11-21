#!/usr/bin/env bash

set -eo pipefail

airnode=0x9E1D2311c407AD0953f6BAa51209C014729D8343
sponsor=0x9F33a4809aA708d7a399fedBa514e0A0d15EfA85
sponsorWallet=0xEadeF1aE573B3Eb6B609D93D7cAD909A798Ca428

. $(dirname $0)/rm-beacon.sh $airnode $sponsor $sponsorWallet
