#!/usr/bin/env bash

set -eo pipefail

airnode=0x1F7A2204b2c255AE6501eeCE29051315ca0aefa4
sponsor=0x9F33a4809aA708d7a399fedBa514e0A0d15EfA85
sponsorWallet=0x9674dc5e867014Ba91E6d53753BcA5D2abcFF9E3

. $(dirname $0)/add-beacon.sh $airnode $sponsor $sponsorWallet
