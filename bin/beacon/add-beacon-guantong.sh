#!/usr/bin/env bash

set -eo pipefail

airnode=0x1F7A2204b2c255AE6501eeCE29051315ca0aefa4
sponsor=0x00000000007317c91F57D86A410934A490E62E1E
sponsorWallet=0x16BE3Aa63f0a9b6898f35D0Bc845A1449B66ef3F

. $(dirname $0)/add-beacon.sh $airnode $sponsor $sponsorWallet
