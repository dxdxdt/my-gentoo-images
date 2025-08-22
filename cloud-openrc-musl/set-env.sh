#!/bin/sh
case $1 in
	*-latest)
		echo 'GH_ARCH=amd64'
		;;
	*-arm*)
		echo 'GH_ARCH=arm64'
		;;
	*)
		exit 2
		;;
esac
