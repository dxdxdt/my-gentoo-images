#!/bin/bash
set -o pipefail

emerge -qv "=sys-kernel/gentoo-sources-$1"

pushd /usr/src/linux
	cp "/opt/kernel/$2" '.config'

	export ARCH=x86
	export CROSS_COMPILE=i486-unknown-linux-musl-
	export INSTALL_PATH=/var/tmp/retrocore/kernel/boot
	export INSTALL_MOD_PATH=/var/tmp/retrocore/kernel
	rm -rf /var/tmp/retrocore/kernel
	make olddefconfig
	make -j $(nproc)
	make install modules_install
popd
pushd /var/tmp/retrocore/kernel
	tar cf "/kernel.tar" *
	sha256sum -b "/kernel.tar" | tee "/kernel.SHA256SUM"
popd
