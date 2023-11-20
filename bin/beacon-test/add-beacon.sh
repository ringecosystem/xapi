#!/usr/bin/env bash

set -eo pipefail

airnode=${1:?}
sponsor=${2:?}
sponsorWallet=${3:?}

c3=$PWD/script/input/c3.json

subapi=$(jq -r ".SUBAPI_ADDR" $c3)

chain=sepolia
endpointId=0xbd452be65dba2428924ea35129292b3247233952dae361d169f2d489d805ce23

data=$(set -x; ethabi encode params \
  -v "(address,bytes32,address,address)" \
  "(${airnode:2},${endpointId:2},${sponsor:2},${sponsorWallet:2})")

sig=$(cast sig "addBeacon((address,bytes32,address,address))")
(set -x; seth send $subapi $sig$data --chain $chain)


chain=crab
endpointId=0x009d6b53b1429850be54c01f42e00985b38c66c57d4742bcb443ee902ed7b7c8

data=$(set -x; ethabi encode params \
  -v "(address,bytes32,address,address)" \
  "(${airnode:2},${endpointId:2},${sponsor:2},${sponsorWallet:2})")

(set -x; seth send $subapi $sig$data --chain $chain)
