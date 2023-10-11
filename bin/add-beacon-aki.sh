#!/usr/bin/env bash

set -eo pipefail

airnode=0xbaA142d0464031990725F0ABfA9dA0e24298650e
sponsor=0xbaA142d0464031990725F0ABfA9dA0e24298650e
sponsorWallet=0x9953D51b3f6A60073737a6De94a19d361108F8Ec

. $(dirname $0)/add-beacon.sh $airnode $sponsor $sponsorWallet
