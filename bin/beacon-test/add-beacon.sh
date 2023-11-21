#!/usr/bin/env bash

set -eo pipefail

airnode=${1:?}
sponsor=${2:?}
sponsorWallet=${3:?}

c3=$PWD/script/input/c3.json

subapi=$(jq -r ".SUBAPI_ADDR" $c3)
sig=$(cast sig "addBeacon(uint256,(uint256,address,bytes32,address,address))")

add_beacon() {
  local chain; chain=${1:?}
  local endpointId; endpointId=${2:?}
  local fromChain; fromChain=${3:?}
  local chainId; chainId=$(seth --to-uint256 $(seth chain-id --chain $fromChain))
  local data;
  data=$(set -x; ethabi encode params \
    -v "(uint256,uint256,address,bytes32,address,address)" \
    "(${chainId:2},${chainId:2},${airnode:2},${endpointId:2},${sponsor:2},${sponsorWallet:2})")
  (set -x; seth send $subapi $sig$data --chain $chain)
}


chain=crab
# ArbitrumSepoliaMessageRoot
fromChain=arbitrum-sepolia
endpointId=0x63400292c39bafe31164968499615317be0f1b97b4122a29d436c8fb427fdf65
# add_beacon $chain $endpointId $fromChain

# SepoliaMessageRoot
fromChain=sepolia
endpointId=0x009d6b53b1429850be54c01f42e00985b38c66c57d4742bcb443ee902ed7b7c8
# add_beacon $chain $endpointId $fromChain


chain=arbitrum-sepolia
# CrabMessageRoot
fromChain=crab
endpointId=0xbd452be65dba2428924ea35129292b3247233952dae361d169f2d489d805ce23
add_beacon $chain $endpointId $fromChain

# SepoliaMessageRoot
fromChain=sepolia
endpointId=0x009d6b53b1429850be54c01f42e00985b38c66c57d4742bcb443ee902ed7b7c8
add_beacon $chain $endpointId $fromChain


chain=sepolia
# CrabMessageRoot
fromChain=crab
endpointId=0xbd452be65dba2428924ea35129292b3247233952dae361d169f2d489d805ce23
add_beacon $chain $endpointId $fromChain

# ArbitrumSepoliaMessageRoot
fromChain=arbitrum-sepolia
endpointId=0x63400292c39bafe31164968499615317be0f1b97b4122a29d436c8fb427fdf65
add_beacon $chain $endpointId $fromChain
