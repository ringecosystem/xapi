.PHONY: all clean fmt test salt deploy

-include .env

all    :; @forge build
clean  :; @forge clean
fmt    :; @forge fmt
test   :; @forge test
salt   :; @./bin/salt.sh
deploy :; @./bin/deploy.sh
