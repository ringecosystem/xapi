#!/usr/bin/env bash

set -eo pipefail

airnode=0xd0431d757f6316821C69BD7477B9659357CFF69F
sponsor=0x701d0d316C98Ca9df43Cb551b5E9F426ee689162
sponsorWallet=0x4AddeA3541336C2cfAFeC454ffB2882549708A45

. $(dirname $0)/add-beacon.sh $airnode $sponsor $sponsorWallet
