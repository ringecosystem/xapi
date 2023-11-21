#!/usr/bin/env bash

set -eo pipefail

c3=$PWD/script/input/c3.json

deployer=$(jq -r ".DEPLOYER" $c3)
ormp=$(jq -r ".ORMP_ADDR" $c3)
subapi=$(jq -r ".SUBAPI_ADDR" $c3)
rrp=$(jq -r ".RRP_ADDR" $c3)

verify() {
  local addr; addr=$1
  local chain_id; chain_id=$2
  local args; args=$3
  local path; path=$4
  local name; name=${path#*:}
  (set -x; forge verify-contract \
    --chain-id $chain_id \
    --num-of-optimizations 999999 \
    --watch \
    --constructor-args $args \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --compiler-version v0.8.17+commit.8df45f5f \
    --show-standard-json-input \
    $addr \
    $path > script/output/$chain_id/$name.v.json)
}

verify $subapi 44 $(cast abi-encode "constructor(address,address,address)" $deployer $rrp $ormp) src/SubAPI.sol:SubAPI
