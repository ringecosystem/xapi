#!/usr/bin/env bash

set -eo pipefail

airnode=0xd0431d757f6316821C69BD7477B9659357CFF69F
sponsor=0x9F33a4809aA708d7a399fedBa514e0A0d15EfA85
sponsorWallet=0xF9587bbf429D985809bba6a12CAaf71e0CC75187

. $(dirname $0)/add-beacon.sh $airnode $sponsor $sponsorWallet
