#!/usr/bin/env bash

set -eo pipefail

airnode=0xd0431d757f6316821C69BD7477B9659357CFF69F
sponsor=0x00000000007317c91F57D86A410934A490E62E1E
sponsorWallet=0x1668C90E4527A991fcD6848e7845163B03582b42

. $(dirname $0)/add-beacon.sh $airnode $sponsor $sponsorWallet
