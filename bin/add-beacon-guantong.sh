#!/usr/bin/env bash

set -eo pipefail

# PangolinMessageRoot
# chain=arbitest
# dapi=0xa681492DBAd5a3999cFCE2d72196d5784dd08D0c
# endpointId=0x23e5743c946604a779a5181a1bf621076cd11687a1f21c8bc2fa483bd704b3ab

# ArbitrumGoerliMessageRoot
chain=pangolin
dapi=0x770713580e5c618A4D29D7E8c0d7604276B63832
endpointId=0xe7fe8a321e9c000326638d5187a650e3f9d0652f30a01ad9ae4a60327e6c5277
airnode=0x1F7A2204b2c255AE6501eeCE29051315ca0aefa4
sponsor=0x9F33a4809aA708d7a399fedBa514e0A0d15EfA85
sponsorWallet=0x9674dc5e867014Ba91E6d53753BcA5D2abcFF9E3

data=$(set -x; ethabi encode params \
  -v "(address,bytes32,address,address)" \
  "(${airnode:2},${endpointId:2},${sponsor:2},${sponsorWallet:2})")

sig=$(cast sig "addBeacon((address,bytes32,address,address))")
(set -x; seth send $dapi $sig$data --chain $chain)
