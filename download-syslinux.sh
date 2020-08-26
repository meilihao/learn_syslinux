#!/usr/bin/env bash
set -e
set -x
echo -e "--- start download-syslinux ---\n\n"

SyslinuxRoot=syslinux-root

mkdir -pv ${SyslinuxRoot} && \
wget --continue --directory-prefix=sources https://mirrors.edge.kernel.org/pub/linux/utils/boot/syslinux/syslinux-6.03.tar.gz && \
tar -xf  syslinux-*.tar.xz -C ${SyslinuxRoot} --strip-components 1

echo -e "--- done download-syslinux ---\n\n"