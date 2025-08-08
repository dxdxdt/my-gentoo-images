#!/bin/bash
set -o pipefail
set -e

USE="symlink" emerge -qv "=sys-kernel/gentoo-sources-$1"

pushd /usr/src/linux
	cp "/opt/kernel/$2" '.config'

	export ARCH=x86
	export CROSS_COMPILE=i486-unknown-linux-musl-
	export INSTALL_PATH=/var/tmp/retrocore/kernel/boot
	export INSTALL_MOD_PATH=/var/tmp/retrocore/kernel
	make olddefconfig
	make -j $(nproc)
	rm -rf /var/tmp/retrocore/kernel
	mkdir -p /var/tmp/retrocore/kernel/boot
	make install modules_install
popd

tar -C /var/tmp/retrocore/kernel -cf "/kernel.tar" boot lib
sha256sum -b "kernel.tar" | tee "kernel.SHA256SUM"
