#!/usr/bin/env bash

set -eo pipefail

airnode=${1:?}
sponsor=${2:?}
sponsorWallet=${3:?}

subapi=0x001F4321429B1E2DF774bdAe0fc62A7394652E0F

arbitest_chain=arbitrum-sepolia
arbitest_endpointId=0xbd452be65dba2428924ea35129292b3247233952dae361d169f2d489d805ce23

arbitest_data=$(set -x; ethabi encode params \
  -v "(address,bytes32,address,address)" \
  "(${airnode:2},${arbitest_endpointId:2},${sponsor:2},${sponsorWallet:2})")

arbitest_sig=$(cast sig "addBeacon((address,bytes32,address,address))")
(set -x; seth send $subapi $arbitest_sig$arbitest_data --chain $arbitest_chain)


crab_chain=crab
crab_endpointId=0x63400292c39bafe31164968499615317be0f1b97b4122a29d436c8fb427fdf65```

crab_data=$(set -x; ethabi encode params \
  -v "(address,bytes32,address,address)" \
  "(${airnode:2},${crab_endpointId:2},${sponsor:2},${sponsorWallet:2})")

crab_sig=$(cast sig "addBeacon((address,bytes32,address,address))")
(set -x; seth send $subapi $crab_sig$crab_data --chain $crab_chain)
