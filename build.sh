#!/bin/bash
#============================================================================
# Authors      : sirius, lprot, smx-smx
# Copyright   : published under GPL
#============================================================================

normal='tput sgr0'
bold='setterm -bold'
lred='printf \033[01;31m'
lgreen='printf \033[01;32m'
lyellow='printf \033[01;33m'
yellow='printf \033[00;33m'
white='printf \033[01;37m'

args=( "$@" )
cwd=$(pwd)
sourcedir=$(cd `dirname $0`; pwd -P)
cross=0
threads=$(cat /proc/cpuinfo | grep siblings | sed -n 1p | awk '{print $3}')

if [ ! -e ./`basename $0` ]; then
	cd $sourcedir
fi

function detect_host(){
if [ -f "${args[0]}" ]; then
	file="${args[0]}"
	$lyellow; printf "Using toolchain file "; $yellow; printf "$file\n"; $normal
	rel=${file%.*}
	cross=1
	tchain=$(cat $file | grep "SET (TCHAINROOT" | awk '{print $3}' | sed 's/"//g;s/)//g') #TCHAINROOT
	t_envname=$(cat $file | grep "SET (DEVNAME" | awk '{print $3}' | sed 's/"//g;s/)//g') #DEVNAME
	tprefix=$(cat $file | grep "SET (T_PREFIX" | awk '{print $3}' | sed 's/"//g;s/)//g') #TPREFIX
	tdest="$tchain/$t_envname"
elif [ "$OSTYPE" == "cygwin" ]; then rel=build_cygwin
elif [ "$OSTYPE" == "linux-gnu" ] || [ "$OSTYPE" == "linux-gnueabi" ]; then rel=build_linux
else
	$lred; "Can't build - unknown OS type. Aborting..."; $normal
	exit 1
fi
}

function main(){
cmake_cross=""
cmake_static=""
detect_host
if [ $cross == 1 ]; then
	toolchainfile="${args[0]}"
	unset args[0]
	args=( "${args[@]}" )
	cmake_cross="-DCMAKE_TOOLCHAIN_FILE="$toolchainfile""
fi
for arg in "${args}"; do
	case $arg in
		"clean")
			clean
			$lgreen; echo "Done!"; $normal
			exit 0;;
		"distclean")
			clean
			cleanconfig
			$lgreen; echo "Done!"; $normal
			exit 0;;
		"configure")
			cleanconfig
			configure;;
		"static")
			cmake_static="-DSTATIC=1"
			configure
			build;;
		"")
			configure
			build;;
		*)
			usage;;
   esac
done
}

function set_cross_arm(){
	PREFIX="$tprefix"
	export CC=$PREFIX-gcc
	export CXX=$PREFIX-g++
	export CPP=$PREFIX-cpp
	export RANLIB=$PREFIX-ranlib
	export PATH="$tchain/bin:$PATH"
}

function check_compile_libs(){
	components=("zlib" "openssl" "lzo2" "glibc")
	versions=("1.2.8" "1.0.1e" "2.06" "2.12.2")
	for component in ${components[@]}; do
		if [ "$component" == "zlib" ]; then
		if [ ! -f "$tdest/lib/libz.a" ]; then
			if [ ! -d "zlib-${versions[0]}" ] && [ ! -f "zlib-${versions[0]}.tar.gz" ]; then
				echo "Downloading zlib..."
				wget "http://prdownloads.sourceforge.net/libpng/zlib-${versions[0]}.tar.gz"
			elif [ ! -d "zlib-${versions[0]}" ] && [ -f "zlib-${versions[0]}.tar.gz" ]; then
				tar xf "zlib-${versions[0]}.tar.gz"
			fi
			tar xf "zlib-${versions[0]}.tar.gz"
				cd "zlib-${versions[0]}"
				./configure --prefix="$tdest"
				make -j$threads
				if [ ! $? == 0 ]; then $lred; echo "Zlib Build Failed!"; $normal; exit 1; fi
				make install
				cd ..
			fi
		elif [ "$component" == "openssl" ]; then
			if [ ! -f "$tdest/lib/libcrypto.a" ] || [ ! -f "$tdest/lib/libssl.a" ]; then
			if [ ! -d "openssl-${versions[1]}" ] && [ ! -f "openssl-${versions[1]}.tar.gz" ]; then
				echo "Downloading openssl..."
				wget "http://www.openssl.org/source/openssl-${versions[1]}.tar.gz"
			elif [ ! -d "openssl-${versions[1]}" ] && [ -f "openssl-${versions[1]}.tar.gz" ]; then
				tar xf "openssl-${versions[1]}.tar.gz"
			fi
			tar xf "openssl-${versions[1]}.tar.gz"
				cd "openssl-${versions[1]}"
				./Configure dist --prefix="$tdest"
				make -j$threads
				if [ ! $? == 0 ]; then $lred; echo "Openssl Build Failed!"; $normal; exit 1; fi
				make install
				cd ..
			fi
		elif [ "$component" == "lzo2" ]; then
			if [ ! -f "$tdest/lib/liblzo2.a" ]; then
			if [ ! -d "lzo-${versions[2]}" ] && [ ! -f "lzo-${versions[2]}.tar.gz" ]; then
				echo "Downloading lzo2..."
				wget "http://www.oberhumer.com/opensource/lzo/download/lzo-${versions[2]}.tar.gz"
			elif [ ! -d "lzo-${versions[2]}" ] && [ -f "lzo-${versions[2]}.tar.gz" ]; then
				tar xf "lzo-${versions[2]}.tar.gz"
			fi
			tar xf "lzo-${versions[2]}.tar.gz"
				cd "lzo-${versions[2]}"
				./configure --host=$tprefix --prefix="$tdest"
				make -j$threads
				if [ ! $? == 0 ]; then $lred; echo "Lzo2 Build Failed!"; $normal; exit 1; fi
				make install
				cd ..
			fi
		elif [ "$component" == "glibc" ]; then
			if [ ! -f "$tdest/lib/libc.a" ]; then
			if [ ! -d "${versions[3]}" ] && [ ! -f "../glibc_${versions[3]}.tgz" ]; then
				echo "You need glibc_${versions[3]}.tgz from lg sources."
				exit 1
			elif [ ! -d "${versions[3]}" ] && [ -f "glibc_${versions[3]}.tgz" ]; then
				tar xf "../glibc_${versions[3]}.tgz"
			fi
			tar xf "../glibc_${versions[3]}.tgz"
				cd "${versions[3]}"
				tar xf glibc-2.12.2.tar.bz2
				tar xf glibc-ports-2.12.2.tar.bz2
				patch -p0 < glibc-2.12.2-cross_hacks-1.patch
				patch -p0 < glibc-2.12.2-wchar.patch
				cd glibc-2.12.2
				ln -s ../glibc-ports-2.12.2 ports
				mkdir build; cd build
				../configure --host=$tprefix --prefix="$tdest"
				make -j$threads
				if [ ! $? == 0 ]; then $lred; echo "Glibc Build Failed!"; $normal; exit 1; fi
				make install
				cd ../..
			fi
		fi
	done

}

function build(){
	if [ $cross == 1 ]; then
	$lyellow; echo "Cross Compiling Libraries for ARM..."; $normal
		if [ ! -d "cross_libs" ]; then
			mkdir cross_libs
		fi
		cd cross_libs
		set_cross_arm
		check_compile_libs
		cd $sourcedir
	fi
	if [ "$cmake_static" == "" ]; then
		$lyellow; echo "Building epk2extract"; $normal
	else
		$lyellow; printf "Building "; $yellow; printf "static"; $lyellow; printf " epk2extract\n"; $normal
	fi

	cd src
	make

	if [ ! $? == 0 ]; then
		$lred; echo "Build Failed!"; $normal
		exit 1
	else
		if [ "$rel" == "build_cygwin" ]; then
			mv epk2extract.exe ../$rel
			if [ "$HOSTTYPE" == "i686" ]; then #cygwin32
				sharedlibs=("cygz.dll" "cygwin1.dll" "cyglzo2-2.dll" "cyggcc_s-1.dll" "cygcrypto-1.0.0.dll")
			elif [ "$HOSTTYPE" == "x86_64" ]; then #cygwin64
				sharedlibs=("cygz.dll" "cygwin1.dll" "cyglzo2-2.dll" "cygcrypto-1.0.0.dll")
			fi
			for cyglib in ${sharedlibs[@]}; do
				$white; echo "Installing $cyglib"; $normal
				islibok=$(which "$cyglib" &>/dev/null; echo $?)
				if [ $islibok == 0 ]; then
					cp `which $cyglib` ../$rel
				else
					$lred
					echo "Something wrong! $cyglib not found."
					echo "Verify your cygwin installation and try again."
					$normal
					exit 1
				fi
			done
		else
			mv epk2extract ../$rel
		fi
		$lgreen; echo "Build completed!"; $normal
		exit 0
	fi
}

function clean(){
	$lyellow; echo "Removing prebuilt files"; $normal
	find . -type f -name "*.a" -delete
	find . -type f -name "*.dll" -delete
	find . -type f -name "epk2extract" -delete
	find . -type f -name "epk2extract.exe" -delete
	find . -depth -name "CMakeFiles" -exec rm -rf '{}' \;
	if [ -d "$rel" ] && [ $(ls "$rel" | wc -l) == 0 ]; then rm -r "$rel"; fi
}

function cleanconfig(){
	$lyellow; echo "Removing cmake cache and make files"; $normal
	find . -type f -name "CMakeCache.txt" -delete
	find . -type f -name "Makefile" -delete
	find . -type f -name "cmake_install.cmake" -delete
}

function configure(){
	if [ ! -e "$rel" ]; then
		mkdir $rel
	fi

	cmake . $cmake_cross $cmake_static
}

function usage(){
$white
echo "$(echoname) build script"
echo "usage:"
echo "$(echo0)			--> build for current host"
echo "$(echo0) $(echo1)	--> cross compile with definitions from a toolchain file [$(echo1)]."
echo "to execute clean/distclean/configure with cross compiling, you can run"
echo "$(echo0) $(echo1) [clean] [distclean] [configure] [static]"
printf "\n"
echo "$(echo0) clean		--> clean prebuilt files and object files"
echo "$(echo0) distclean		--> same as above, but removes configuration aswell"
echo "$(echo0) configure		--> creates new Makefiles. run distclean first to remove the old configuration"
echo "$(echo0) static		--> Statically link executable"
$normal
}

function echoname(){
$bold; $lgreen; printf "epk"; $lyellow; printf "2"; $lred; printf "extract"; $normal; $white
}

function echo0(){
$lyellow; printf $0; $white
}

function echo1(){
$yellow; printf "arm_lgtv.cmake"; $white
}
main
