To compile on Linux:
==============================

# 1 - Installing build dependencies
If you are running Ubuntu or Linux Mint, you can run
sudo apt-get install git build-essential cmake liblzo2-dev libssl-dev libc6-dev-i386

# 2 - Running build
./build.sh

Compiled program can be found at build_linux/bin/


To compile on cygwin:
==============================

# 1 - Installing build dependencies
From cygwin setup, install:
gcc git cmake liblzo2-devel openssl-devel

# 2 - Running build
./build.sh

Compiled program can be found at build_cygwin/bin/
The build script automatically copies cygwin shared libraries to the bin folder, so you can use epk2extract
without having to install cygwin


## To use:
Put *.pem and AES.key to epk2extract folder.
Run it via sudo because rootfs extraction needs root:
sudo ./epk2extract file

## To to get IDC from SYM run:
./epk2extract xxxxxxxx.sym

## Known issues:
Sometimes Uncramfs segfaults or Unsquashfs does "Read on filesystem failed because Bad file descriptor". 
In that case just run epk2extract again and it will do the job right.

epk2extract might use a large amount of RAM while running and thus slow down your computer.
If the program or your computer seem frozen or not responding please be patient and give it some time to finish.