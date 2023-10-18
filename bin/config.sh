#!/usr/bin/env bash

set -eo pipefail

forge script script/Config.s.sol:Config --chain-id 44     --broadcast
forge script script/Config.s.sol:Config --chain-id 421614 --broadcast --skip-simulation
