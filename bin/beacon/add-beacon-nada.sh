#!/usr/bin/env bash

set -eo pipefail

airnode=0xd0431d757f6316821C69BD7477B9659357CFF69F
sponsor=0x000000000a0D8ac9cc6CbD817fA77090322FF29d
sponsorWallet=0x1668C90E4527A991fcD6848e7845163B03582b42

. $(dirname $0)/add-beacon.sh $airnode $sponsor $sponsorWallet
