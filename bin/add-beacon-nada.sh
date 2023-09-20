#!/usr/bin/env bash

set -eo pipefail

airnode=0xd0431d757f6316821C69BD7477B9659357CFF69F
sponsor=0x701d0d316C98Ca9df43Cb551b5E9F426ee689162
sponsorWallet=0x4AddeA3541336C2cfAFeC454ffB2882549708A45

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
  "(${airnode:2},${pangolin_endpointId:2},${sponsor:2},${sponsorWallet:2})")

pangolin_sig=$(cast sig "addBeacon((address,bytes32,address,address))")
(set -x; seth send $pangolin_dapi $pangolin_sig$pangolin_data --chain $pangolin_chain)
