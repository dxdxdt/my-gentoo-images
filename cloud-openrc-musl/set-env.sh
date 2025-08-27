#!/bin/sh
case $1 in
	*-latest)
		echo 'GH_ARCH=amd64'
		echo 'GH_GRUB_TARGET=x86_64-efi'
		;;
# Both arm and arm64 are treated as arm64. Blame Github for this poor design
# taste.
	*-arm*)
		echo 'GH_ARCH=arm64'
		echo 'GH_GRUB_TARGET=arm64-efi'
		;;
	*)
		exit 2
		;;
esac
