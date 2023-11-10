#!/usr/bin/env bash

set -eo pipefail

c3=$PWD/script/input/c3.json

deployer=$(jq -r ".DEPLOYER" $c3)
subapi=$(jq -r ".SUBAPI_ADDR" $c3)
dao=$(jq -r ".SUBAPIDAO" $c3)

seth send -F $deployer $subapi "transferOwnership(address)" $dao --chain darwinia
seth send -F $deployer $subapi "transferOwnership(address)" $dao --chain arbitrum
