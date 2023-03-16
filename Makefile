# profiles.mk provides guix version specified by rde/channels-lock.scm
# To rebuild channels-lock.scm use `make -B rde/channels-lock.scm`
include profiles.mk

# Also defined in .envrc to make proper guix version available project-wide
GUIX_PROFILE=target/profiles/guix
GUIX=./pre-inst-env ${GUIX_PROFILE}/bin/guix


pinephone-pro-kernel: guix
	${GUIX} build -e '(@ (config) pinephone-pro-kernel)' \
	--target="aarch64-linux-gnu"

repl: guix
	${GUIX} repl --listen=tcp:37146

target:
	mkdir -p target

minimal/home/build: guix
	${GUIX} home build ./src/abcdw/minimal.scm

clean-target:
	rm -rf ./target

clean: clean-target
