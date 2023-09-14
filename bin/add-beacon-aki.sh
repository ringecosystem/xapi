#!/usr/bin/env bash

set -eo pipefail

airnode=0xbaA142d0464031990725F0ABfA9dA0e24298650e
sponsor=0xD93E82b9969CC9a016Bc58f5D1D7f83918fd9C79
sponsorWallet=0xeC16f8AfFeb57687357c01eF1645392a4c00644D

arbitest_chain=arbitest
arbitest_dapi=0xa681492DBAd5a3999cFCE2d72196d5784dd08D0c
arbitest_endpointId=0x23e5743c946604a779a5181a1bf621076cd11687a1f21c8bc2fa483bd704b3ab

arbitest_data=$(set -x; ethabi encode params \
  -v "(address,bytes32,address,address)" \
  "(${airnode:2},${arbitest_endpointId:2},${sponsor:2},${sponsorWallet:2})")

arbitest_sig=$(cast sig "addBeacon((address,bytes32,address,address))")
(set -x; seth send $arbitest_dapi $arbitest_sig$arbitest_data --chain $arbitest_chain)


pangolin_chain=pangolin
pangolin_dapi=0x770713580e5c618A4D29D7E8c0d7604276B63832
pangolin_endpointId=0xe7fe8a321e9c000326638d5187a650e3f9d0652f30a01ad9ae4a60327e6c5277

pangolin_data=$(set -x; ethabi encode params \
  -v "(address,bytes32,address,address)" \
  "(${airnode:2},${arbitest_endpointId:2},${sponsor:2},${sponsorWallet:2})")

pangolin_sig=$(cast sig "addBeacon((address,bytes32,address,address))")
(set -x; seth send $pangolin_dapi $pangolin_sig$pangolin_data --chain $pangolin_chain)
