#!/usr/bin/env bash

set -eo pipefail

c3=$PWD/script/input/c3.json
subapi=$(jq -r ".SUBAPIMULTISIG_ADDR" $c3)

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

parameters=0x000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000005000000000000000000000000178e699c9a6bb2cd624557fbd85ed219e6faba770000000000000000000000009f33a4809aa708d7a399fedba514e0a0d15efa85000000000000000000000000a4be619e8c0e3889f5fa28bb0393a4862cad35ad000000000000000000000000b9a0cadd13c5d534b034d878b2fca9e5a6e1e3a4000000000000000000000000fa5727be643dba6599fc7f812fe60da3264a8205
# verify $subapi 11155111  $parameters src/SubAPIMultiSig.sol:SubAPIMultiSig
verify $subapi 43 $parameters src/SubAPIMultiSig.sol:SubAPIMultiSig
# verify $subapi 421614 $parameters src/SubAPIMultiSig.sol:SubAPIMultiSig
