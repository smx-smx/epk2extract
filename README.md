To compile on Ubuntu:
==============================

apt-get install git build-essential cmake liblzo2-dev libssl-dev libc6-dev-i386
./build.sh

Compiled program can be found at build/src/epk2extract

## To use:
Put *.pem and AES.key to epk2extract folder.
Run it via sudo because rootfs extraction needs root:
sudo ./epk2extract file

## To to get IDC from SYM run:
./epk2extract xxxxxxxx.sym

## Known issues:
Sometimes it segfaults or fails to write something. In that case just run it again.
