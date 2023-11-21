#!/usr/bin/env bash

set -eo pipefail

airnode=0xbaA142d0464031990725F0ABfA9dA0e24298650e
sponsor=0x9F33a4809aA708d7a399fedBa514e0A0d15EfA85
sponsorWallet=0x534516FA00D43B8799a9cd29E7E48283f029FA23

. $(dirname $0)/rm-beacon.sh $airnode $sponsor $sponsorWallet
