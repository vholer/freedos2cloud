# FreeDOS Installation Media
FDOS_VERSION      ?= 1.3
FDOS_VERSION_M    ?= $(subst .,,${FDOS_VERSION})
FDOS_BASE_URL     ?= https://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions
FDOS_FILENAME     ?= previews/1.3-rc4/FD${FDOS_VERSION_M}-LiveCD.zip
FDOS_URL          ?= ${FDOS_BASE_URL}/${FDOS_VERSION}/${FDOS_FILENAME}
FDOS_ISO_NAME     ?= FD${FDOS_VERSION_M}LIVE.iso
FDOS_ISO_CHECKSUM ?= 0655c630271ad4b64228614c21a4a834d010a31d0deac88c8dd6eb2efba47a952892820d55ad474e0d892b7da3b24c9dfeb746c0772a2a9242c1895098f12a1d

# Additional software
RMENU_URL ?= https://www.bttr-software.de/products/jhoffmann/rmenu-17.zip

.DEFAULT_GOAL := build/image/freedos-${FDOS_VERSION}.qcow2

build/source/${FDOS_ISO_NAME}:
	mkdir -p build/source
	curl "${FDOS_URL}" -o $@s.zip
	unzip -DDo $@s.zip ${FDOS_ISO_NAME} -d build/source
	unlink $@s.zip

build/source/rmenu.zip:
	curl "${RMENU_URL}" -o $@

build/image/freedos-${FDOS_VERSION}.qcow2: build/source/${FDOS_ISO_NAME} build/source/rmenu.zip src/
	rm -rf build/image
	packer build \
		-var "fdos_version=${FDOS_VERSION}" \
		-var "iso_file=$(realpath $<)" \
		-var "iso_checksum=${FDOS_ISO_CHECKSUM}" \
		.

clean:
	-rm -rf build/image

distclean:
	-rm -rf build
