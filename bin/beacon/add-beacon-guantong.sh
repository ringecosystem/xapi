#!/usr/bin/env bash

set -eo pipefail

airnode=0x1F7A2204b2c255AE6501eeCE29051315ca0aefa4
sponsor=0x000000000a0D8ac9cc6CbD817fA77090322FF29d
sponsorWallet=0x16BE3Aa63f0a9b6898f35D0Bc845A1449B66ef3F

. $(dirname $0)/add-beacon.sh $airnode $sponsor $sponsorWallet
