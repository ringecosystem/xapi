.PHONY: all clean fmt test salt deploy config verify

-include .env

all    :; @forge build --force
clean  :; @forge clean
fmt    :; @forge fmt
test   :; @forge test
salt   :; @./bin/salt.sh
deploy :; @./bin/deploy.sh
config :; @./bin/config.sh
verify :; @./bin/verify.sh
