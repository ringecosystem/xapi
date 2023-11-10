#!/usr/bin/env bash

set -eo pipefail

airnode=${1:?}
sponsor=${2:?}
sponsorWallet=${3:?}

c3=$PWD/script/input/c3.json

subapi=$(jq -r ".SUBAPI_ADDR" $c3)

chain=arbitrum
endpointId=0x45189e2288f2d2e384c9e3be7c3c6cef65a553341ca8580e1ed3516725112bb4

data=$(set -x; ethabi encode params \
  -v "(address,bytes32,address,address)" \
  "(${airnode:2},${endpointId:2},${sponsor:2},${sponsorWallet:2})")

sig=$(cast sig "addBeacon((address,bytes32,address,address))")
(set -x; seth send $subapi $sig$data --chain $chain)


chain=darwinia
endpointId=0x18905d41e909c79069d74843dc474d0809df62b5bc555ea272b0cc49ff3fa924

data=$(set -x; ethabi encode params \
  -v "(address,bytes32,address,address)" \
  "(${airnode:2},${endpointId:2},${sponsor:2},${sponsorWallet:2})")

(set -x; seth send $subapi $sig$data --chain $chain)
