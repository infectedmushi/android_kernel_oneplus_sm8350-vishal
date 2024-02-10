#!/usr/bin/env bash

TARGET_ARCH=arm64;
TARGET_CC=/mnt/Bathtube/toolchains/proton-clang-16/bin/clang;
TRAGET_CLANG_TRIPLE=aarch64-linux-gnu-;
TARGET_CROSS_COMPILE=/mnt/Bathtube/toolchains/gcc-linaro-12.3.1-2023.06-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-;
TARGET_CROSS_COMPILE_ARM32=/mnt/Bathtube/toolchains/gcc-linaro-12.3.1-2023.06-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-;
THREAD=32;
TARGET_OUT=out;
FINAL_KERNEL_BUILD_PARA="ARCH=$TARGET_ARCH \
                         CC=$TARGET_CC \
                         CROSS_COMPILE=$TARGET_CROSS_COMPILE \
                         CROSS_COMPILE_COMPAT=$TARGET_CROSS_COMPILE_ARM32 \
                         CLANG_TRIPLE=$TARGET_CLANG_TRIPLE \
                         -j$THREAD \
                         O=out";

TARGET_KERNEL_FILE=out/arch/arm64/boot/Image;
TARGET_KERNEL_DTB=out/arch/arm64/boot/dtb;
TARGET_KERNEL_DTBO=out/arch/arm64/boot/dtbo.img

DEFCONFIG="vendor/lahaina-qgki_defconfig";

if ! make $FINAL_KERNEL_BUILD_PARA $DEFCONFIG; then
    exit 1
fi

if ! make $FINAL_KERNEL_BUILD_PARA; then
    exit 2
fi

rm -r out/ak3
cp -r ak3 out/

cp out/arch/arm64/boot/Image out/ak3/Image
#cp out/arch/arm64/boot/dtbo.img out/ak3/dtbo.img
find out/arch/arm64/boot/dts/vendor -name '*.dtb' -exec cat {} + > out/ak3/dtb;

cd out/ak3
zip -r9 deepongi-aospa-$(/bin/date -u '+%Y%m%d-%H%M').zip .

