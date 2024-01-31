.PHONY: all clean fmt test salt deploy config verify create3 add

-include .env

all    :; @forge build --force
clean  :; @forge clean
fmt    :; @forge fmt
test   :; @forge test
salt   :; @create3 -s 000000000000
deploy :; @./bin/multisig_deploy.sh
config :; @./bin/config.sh
verify :; @./bin/verify.sh
create3:; @cargo install --git https://github.com/darwinia-network/create3-deploy -f
add    :; @./bin/beacon/add-all.sh
