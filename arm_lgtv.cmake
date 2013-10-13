#TCHAINROOT --> Toolchain root (with bin folder)
#T_PREFIX   --> Initial name of the binaries. Example: armv7a-mediatek451_001_vfp-linux-gnueabi.
#				"-gcc", "-ld" and such are automatically appended
#DEVNAME	--> Cross Environment name (folder in Toolchain Root). Example: armv7a-mediatek-linux-gnueabi

SET (CMAKE_SYSTEM_NAME Linux)
SET (CMAKE_SYSTEM_VERSION 1)
SET_PROPERTY(GLOBAL PROPERTY TARGET_SUPPORTS_SHARED_LIBS FALSE)
SET (TCHAINROOT /opt/gnuarm_4.5.1_cortex-a9_vfp_002/vfp_4.5.1_2.6.27_cortex-a9-rhel4_002/i686)
SET (T_PREFIX "armv7a-mediatek451_001_vfp-linux-gnueabi")
SET (DEVNAME armv7a-mediatek-linux-gnueabi)
SET (DEVROOT ${TCHAINROOT}/${DEVNAME})
SET (CMAKE_C_COMPILER "${TCHAINROOT}/bin/${T_PREFIX}-gcc")

INCLUDE_DIRECTORIES(SYSTEM "${DEVROOT}/include")
LINK_DIRECTORIES("${DEVROOT}/lib")

SET (CMAKE_FIND_ROOT_PATH "${DEVROOT}")
SET (CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)
SET (CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET (CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
