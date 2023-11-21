#!/usr/bin/env bash

set -eo pipefail

# forge script script/Deploy.s.sol:Deploy --chain-id 46    --broadcast --verify --slow
# forge script script/Deploy.s.sol:Deploy --chain-id 42161 --broadcast --verify --slow --legacy

# forge script script/Deploy.s.sol:Deploy --chain-id 11155111    --broadcast --verify
forge script script/Deploy.s.sol:Deploy --chain-id 44    --broadcast --verify
