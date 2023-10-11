#!/usr/bin/env bash

set -eo pipefail

chain=${1:?}
addr=0x00533dff7900e37e7c9bbbdfa1d703f6c099b409
salt=0x6de7d18dae1b7fa349ad72fba1d8b121b85b0e0fd6e087e872df0f5421a8a0af

deployer=0x0f14341A7f464320319025540E8Fe48Ad0fe5aec
create2=0x914d7Fec6aaC8cd542e72Bca78B30650d45643d7
ormp=0x0000000000BD9dcFDa5C60697039E2b3B28b079b
out_dir=$PWD/out
bytecode=$(jq -r '.contracts["src/ORMPWrapper.sol"].ORMPWrapper.evm.bytecode.object' $out_dir/dapp.sol.json)
args=$(ethabi encode params -v address ${ormp:2})
initcode=$bytecode$args

data=$salt$initcode
addr1=$(seth call -F $deployer $create2 $data --chain $chain)

if [[ $(seth --to-checksum-address "${addr}") == $(seth --to-checksum-address "${addr1}") ]]; then
  seth send -F $deployer $create2 $data --chain $chain
else
  echo "Address does not match!"
  exit 1
fi
