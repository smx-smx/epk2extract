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
Sometimes Uncramfs segfaults or Unsquashfs does "Read on filesystem failed because Bad file descriptor". 
In that case just run epk2extract again and it will do the job right.
