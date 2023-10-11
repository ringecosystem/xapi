#!/usr/bin/env bash

set -eo pipefail

airnode=0x9E1D2311c407AD0953f6BAa51209C014729D8343
sponsor=0x9E1D2311c407AD0953f6BAa51209C014729D8343
sponsorWallet=0x064115a572aCCacD5bb39236C46eE8A1D0631182

. $(dirname $0)/add-beacon.sh $airnode $sponsor $sponsorWallet
