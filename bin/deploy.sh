#!/usr/bin/env bash

set -eo pipefail

forge script script/Deploy.s.sol:Deploy --chain-id 44     --broadcast --verify
forge script script/Deploy.s.sol:Deploy --chain-id 421614 --broadcast --verify
