.PHONY: all clean fmt test salt deploy

all    :; @forge build
clean  :; @forge clean
fmt    :; @forge fmt
test   :; @forge test
salt   :; @./bin/salt.sh
deploy :; @./bin/deploy.sh
