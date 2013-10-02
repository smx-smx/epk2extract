#!/bin/bash
#============================================================================
# Authors      : sirius, lprot, smx
# Copyright   : published under GPL
#============================================================================

normal='tput sgr0'
lred='printf \033[01;31m'
lgreen='printf \033[01;32m'
lyellow='printf \033[01;33m'
white='printf \033[01;37m'

cwd=$(pwd)
if [ ! -e $0 ]; then
	$lyellow; echo "Please run this script from the source directory"; $normal
	exit 1
fi
if [ ! "$1" == "clean" ]; then
	$lyellow; echo "Building epk2extract"; $normal
	if [ -f "build" ]; then
		$lred; echo "A file named \"build\" exists. Please move it"; $normal
		exit 1
	elif [ ! -e "build" ]; then
		mkdir build
	fi

	cd build
	cmake ..
	make
	if [ ! $? == 0 ]; then
		$lred; echo "Build Failed!"; $normal
		exit 1
	else
		$lgreen; echo "Build Completed!"; $normal
		exit 0
	fi
else
	$lyellow; echo "Removing epk2extract build directory"; $normal
	if [ -d "build" ]; then
		yes | rm -r build
	fi
	if [ ! -d "build" ]; then
		$lgreen; echo "Done!"; $normal
		exit 0
	else
		$lred; echo "Error!"; $normal
		exit 1
	fi
fi
