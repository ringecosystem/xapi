#!/usr/bin/env bash

set -eo pipefail

airnode=0xbaA142d0464031990725F0ABfA9dA0e24298650e
sponsor=0x000000000a0D8ac9cc6CbD817fA77090322FF29d
sponsorWallet=0xF17fe0E7230835A74b49c4cae20759F7fAb40f31

. $(dirname $0)/add-beacon.sh $airnode $sponsor $sponsorWallet
