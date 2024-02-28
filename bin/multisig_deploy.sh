#!/usr/bin/env bash

set -eo pipefail

# forge script script/Deploy.s.sol:Deploy --chain-id 46    --broadcast --verify --slow
# forge script script/Deploy.s.sol:Deploy --chain-id 42161 --broadcast --verify --slow --legacy
# forge script script/Deploy.s.sol:Deploy --chain-id 1     --broadcast --verify --slow --legacy

# forge script script/MultiSigDeploy.s.sol:MultiSigDeploy --chain-id 43       --broadcast --verify --skip-simulation
# forge script script/MultiSigDeploy.s.sol:MultiSigDeploy --chain-id 421614   --broadcast --verify --skip-simulation
# forge script script/MultiSigDeploy.s.sol:MultiSigDeploy --chain-id 11155111 --broadcast --verify --skip-simulation

# forge script script/MultiSigDeploy.s.sol:MultiSigDeploy --chain-id 1     --broadcast --verify --legacy  --with-gas-price 31000000000
# forge script script/MultiSigDeploy.s.sol:MultiSigDeploy --chain-id 44   --broadcast --verify
# forge script script/MultiSigDeploy.s.sol:MultiSigDeploy --chain-id 46    --broadcast --verify
forge script script/MultiSigDeploy.s.sol:MultiSigDeploy --chain-id 137    --broadcast --verify --with-gas-price 150000000000 
# forge script script/MultiSigDeploy.s.sol:MultiSigDeploy --chain-id 42161 --legacy --broadcast --verify --skip-simulation
