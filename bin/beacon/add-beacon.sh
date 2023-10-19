#!/usr/bin/env bash

set -eo pipefail

airnode=${1:?}
sponsor=${2:?}
sponsorWallet=${3:?}

subapi=0x007471Db6AD668b30a7CE648589a4C8C4f65a36f

arbitest_chain=arbitrum-sepolia
arbitest_endpointId=0x23e5743c946604a779a5181a1bf621076cd11687a1f21c8bc2fa483bd704b3ab

arbitest_data=$(set -x; ethabi encode params \
  -v "(address,bytes32,address,address)" \
  "(${airnode:2},${arbitest_endpointId:2},${sponsor:2},${sponsorWallet:2})")

arbitest_sig=$(cast sig "addBeacon((address,bytes32,address,address))")
(set -x; seth send $subapi $arbitest_sig$arbitest_data --chain $arbitest_chain)


crab_chain=crab
crab_endpointId=0xe7fe8a321e9c000326638d5187a650e3f9d0652f30a01ad9ae4a60327e6c5277

crab_data=$(set -x; ethabi encode params \
  -v "(address,bytes32,address,address)" \
  "(${airnode:2},${crab_endpointId:2},${sponsor:2},${sponsorWallet:2})")

crab_sig=$(cast sig "addBeacon((address,bytes32,address,address))")
(set -x; seth send $subapi $crab_sig$crab_data --chain $crab_chain)
