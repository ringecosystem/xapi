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
  # (set -x; seth send $subapi $sig$data --chain $chain)
}

# chain=darwinia
# fromChain=arbitrum
# endpointId=0x18905d41e909c79069d74843dc474d0809df62b5bc555ea272b0cc49ff3fa924
# add_beacon $chain $endpointId $fromChain

# fromChain=ethereum
# endpointId=0xd3b815c7ac0ba9242a379bdc8a2f94d609e64239c6c85ac27e244828d6f48815
# add_beacon $chain $endpointId $fromChain

chain=arbitrum
fromChain=darwinia
endpointId=0x45189e2288f2d2e384c9e3be7c3c6cef65a553341ca8580e1ed3516725112bb4
add_beacon $chain $endpointId $fromChain

fromChain=ethereum
endpointId=0xd3b815c7ac0ba9242a379bdc8a2f94d609e64239c6c85ac27e244828d6f48815
add_beacon $chain $endpointId $fromChain

# chain=ethereum
# fromChain=darwinia
# endpointId=0x45189e2288f2d2e384c9e3be7c3c6cef65a553341ca8580e1ed3516725112bb4
# add_beacon $chain $endpointId $fromChain

# fromChain=arbitrum
# endpointId=0x18905d41e909c79069d74843dc474d0809df62b5bc555ea272b0cc49ff3fa924
# add_beacon $chain $endpointId $fromChain
