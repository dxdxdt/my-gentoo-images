#!/bin/bash
set -e
set -o pipefail

declare -r DOCKER_IMAGE="$1"
declare -r OUTPUT_IMAGE="$2"
declare -r GRUB_TARGET="$3"
declare -r LABEL_ESP="GENTOO-ESP"
declare -r LABEL_ROOT="gentoo-root"

container_id=$(docker run -d "$DOCKER_IMAGE")
docker wait "$container_id" > /dev/null

rootfs_size=$(docker run --rm -i "$DOCKER_IMAGE" du -sxb / | cut -f1)
let 'imglen = rootfs_size / 1073741824 + 3'
fallocate -l ${imglen}G "$OUTPUT_IMAGE"

parted -s "$OUTPUT_IMAGE" \
	mkt gpt \
	mkp "esp" fat32 2M 52M \
	set 1 esp on \
	mkp "root" xfs 52M 100%
lodev=$(losetup --show -fP "$OUTPUT_IMAGE")
mkfs.vfat -n "$LABEL_ESP" "${lodev}p1"
mkfs.xfs -L "$LABEL_ROOT" "${lodev}p2"

mkdir -p /mnt/gentoo
mount "${lodev}p2" /mnt/gentoo
# no xattr in Docker container. the option is kept just as a future-proof
docker export "$container_id" | \
	tar xf - --xattrs-include='*.*' --numeric-owner -C /mnt/gentoo
rm -rf /mnt/gentoo/boot/efi
mkdir -p /mnt/gentoo/boot/efi
mount "${lodev}p1" /mnt/gentoo/boot/efi

mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run
mount --make-slave /mnt/gentoo/run

rm -f /mnt/gentoo/etc/fstab
echo "LABEL=$LABEL_ROOT  / xfs defaults 0 1" >> /mnt/gentoo/etc/fstab
echo "LABEL=$LABEL_ESP /boot/efi defaults 1 2" >> /mnt/gentoo/etc/fstab

chroot \
	/mnt/gentoo grub-install \
	--efi-directory=/boot/efi \
	--removable \
	--target=$GRUB_TARGET
chroot /mnt/gentoo grub-mkconfig -o /boot/grub/grub.cfg

umount -R /mnt/gentoo
losetup -d "${lodev}"
sync
