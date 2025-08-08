#!/bin/bash
set -e
set -o pipefail

mkdir -p /boot/efi

emerge-webrsync
eselect profile set default/linux/$1/23.0/musl

emerge --update --deep --changed-use @world
emerge --depclean

echo 'sys-kernel/installkernel grub dracut' > /etc/portage/package.use/installkernel
echo 'USE="${USE} dist-kernel"' >> /etc/portage/make.conf
echo 'GRUB_PLATFORMS="efi-64"' >> /etc/portage/make.conf
emerge -qv sys-kernel/installkernel
echo 'hostonly="no"' >> /etc/dracut.conf

#emerge -qv sys-kernel/linux-firmware
# https://bugs.gentoo.org/958594
ACCEPT_KEYWORDS="~$1" emerge -qv '>=sys-kernel/gentoo-kernel-6.12.39'

USE=netifrc emerge -qv app-emulation/cloud-init
echo 'locale: false' > /etc/cloud/cloud.cfg.d/99-musl-disable-locale.cfg
rc-update add cloud-init-ds-identify boot
rc-update add cloud-init-local boot
rc-update add cloud-config
rc-update add cloud-final
rc-update add cloud-init
rc-update add cloud-init-hotplug

emerge -qv \
	net-misc/dhcpcd sys-power/acpid sys-boot/grub app-admin/sudo \
	sys-process/cronie app-shells/bash-completion net-misc/chrony \
	sys-fs/dosfstools sys-fs/e2fsprogs sys-fs/xfsprogs \
	sys-block/io-scheduler-udev-rules sys-fs/growpart

rc-update add sshd
rc-update add cronie
rc-update add chronyd
rc-update add acpid
