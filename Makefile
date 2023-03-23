# profiles.mk provides guix version specified by rde/channels-lock.scm
# To rebuild channels-lock.scm use `make -B rde/channels-lock.scm`
include profiles.mk

# Also defined in .envrc to make proper guix version available project-wide
GUIX_PROFILE=target/profiles/guix
GUIX=./pre-inst-env ${GUIX_PROFILE}/bin/guix
PINEPHONE_STORAGE=/dev/XXX

pinephone-pro-firmware: guix
	${GUIX} build -e '(@ (config) pinephone-pro-firmware)' \
	--target="aarch64-linux-gnu"

pinephone-pro-kernel: guix
	${GUIX} build -e '(@ (config) pinephone-pro-kernel)' \
	--target="aarch64-linux-gnu" # --keep-failed

pinephone-pro-image: guix
	${GUIX} system image --image-type=rock64-raw ./src/config.scm \
	# --target="aarch64-linux-gnu"

write-image: guix
	sudo dd if=`${GUIX} system image --image-type=rock64-raw ./src/config.scm` \
	of=${PINEPHONE_STORAGE} bs=1M oflag=direct,sync status=progress

repl: guix
	${GUIX} repl --listen=tcp:37146

target:
	mkdir -p target

minimal/home/build: guix
	${GUIX} home build ./src/abcdw/minimal.scm

clean-target:
	rm -rf ./target

clean: clean-target
