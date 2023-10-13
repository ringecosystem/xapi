#!/usr/bin/env bash

set -eo pipefail

deployer=0x0f14341A7f464320319025540E8Fe48Ad0fe5aec
create2=0x914d7Fec6aaC8cd542e72Bca78B30650d45643d7
ormp=0x0000000000BD9dcFDa5C60697039E2b3B28b079b

out_dir=$PWD/out
bytecode=$(jq -r '.bytecode.object' $out_dir/SubAPI.sol/SubAPI.json)

args=$(ethabi encode params -v address ${ormp:2})
initcode=$bytecode$args

out=$(cast create2 -i $initcode -d $create2 --starts-with "00" | grep -E '(Address:|Salt:)')
addr=$(echo $out | awk '{print $2}' )
salt=$(seth --to-uint256 $(echo $out | awk '{print $4}' ))
echo -e "SubAPI: \n Addr: $addr \n Salt: $salt"
