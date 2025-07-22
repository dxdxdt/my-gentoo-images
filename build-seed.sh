#!/bin/bash
set -o pipefail

# crossdev stages

eselect repository create crossdev
crossdev -s4 -t i486-unknown-linux-musl
PORTAGE_CONFIGROOT=/usr/i486-unknown-linux-musl \
	eselect profile set default/linux/x86/23.0/i486/split-usr/musl

#
# Rebuild crossdev stage 2 GCC with openmp support.
# USE="openmp" is overridden in crossdev so running it with the USE flags won't
# solve the issue. I know This is wasteful because know the following command
# triggers huge reinstall of all dependencies. That's just how the -e option
# works.
# See https://bugs.gentoo.org/909453 (obviously, the patch didn't work)

USE="openmp" emerge -qv -e '>cross-i486-unknown-linux-musl/gcc-0.0.0'

#
# Default to gnu17 to avoid K&R style function call issues (getenv() declaration
# mismatch). There may be many other packages that still depend on pre GCC-15's
# default -std=gnu17
# See:
# https://bugs.gentoo.org/show_bug.cgi?id=gcc-15
# https://bugs.gentoo.org/944111
# https://gitweb.gentoo.org/repo/gentoo.git/commit/?id=fe38bc92d691141210537b93a8e354b6f6ea7c36
# https://gitweb.gentoo.org/repo/gentoo.git/commit/?id=1d042be2d8cb16f0a2c8a74611433346d2950760
# https://gitweb.git.savannah.gnu.org/gitweb/?p=gperf.git;a=commit;h=cabd2af10e509b7889b57f9ef21ec3e08e85c8e6
# https://gcc.gnu.org/bugzilla/show_bug.cgi?id=118112

mkdir -p '/usr/i486-unknown-linux-musl/etc/portage/env'
cat << 'EOF' > '/usr/i486-unknown-linux-musl/etc/portage/env/std-gnu17.conf'
CFLAGS="${CFLAGS} -std=gnu17"
EOF
cat << 'EOF' > '/usr/i486-unknown-linux-musl/etc/portage/package.env'
sys-apps/groff std-gnu17.conf
dev-build/make std-gnu17.conf
EOF
# bash(1): If any part of word is quoted, the delimiter is the result of quote
# removal on word,  and  the lines in the here-document are not expanded.

# Optimise for size. Bloated modern SW would be big for old 486 HW
echo 'CFLAGS="${CFLAGS} -Os"' >> '/usr/i486-unknown-linux-musl/etc/portage/make.conf'
echo 'CXXFLAGS="${CXXFLAGS} -Os"' >> '/usr/i486-unknown-linux-musl/etc/portage/make.conf'

# Let her rip!
CC=i486-unknown-linux-musl-cc AR=i486-unknown-linux-musl-ar \
	i486-unknown-linux-musl-emerge -qv1 @system

# Archive
pushd /var/log
	tar --zstd -cf /i486-musl-seed.logs.tar.zst *
popd
pushd /usr/i486-unknown-linux-musl
	tar --zstd -cf /i486-musl-seed.tar.zst *
popd
sha256sum -b i486-musl-seed.tar.zst | tee i486-musl-seed.SHA256SUM
