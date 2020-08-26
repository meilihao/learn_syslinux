#!/usr/bin/env bash
set -e
#set -x

echo -e "--- start isolinux-basic.sh ---\n\n"
# https://www.chengweiyang.cn/2011/08/13/create-linux-system-iso/

SyslinuxRoot=../syslinux-root
DemoRoot=isolinux-kernel

mkdir -pv ${DemoRoot}
rm -rf ${DemoRoot}/isolinux || true
mkdir -pv ${DemoRoot}/isolinux

UI='vesamenu.c32'

cp ${SyslinuxRoot}/bios/core/isolinux.bin ${DemoRoot}/isolinux
cp ${SyslinuxRoot}/bios/com32/elflink/ldlinux/ldlinux.c32 ${DemoRoot}/isolinux
cp ${SyslinuxRoot}/bios/com32/libutil/libutil.c32 ${DemoRoot}/isolinux
cp ${SyslinuxRoot}/bios/com32/lib/libcom32.c32 ${DemoRoot}/isolinux
cp ${SyslinuxRoot}/bios/com32/menu/vesamenu.c32 ${DemoRoot}/isolinux

# kernel 5.4.30
cp /boot/vmlinuz-5.4.50-amd64-desktop ${DemoRoot}/isolinux/vmlinuz # 9.1M
cp /boot/initrd.img-5.4.50-amd64-desktop ${DemoRoot}/isolinux/initrd # 65M

TIMEOUT 60 = 6s
cat > ${DemoRoot}/isolinux/isolinux.cfg <<EOF
UI ${UI}
TIMEOUT 60
label ${DemoRoot}
    menu label ${DemoRoot}
    KERNEL vmlinuz
    INITRD initrd
    APPEND rw root=/dev/ram0
EOF

# 同上类似
# cat > ${DemoRoot}/isolinux/isolinux.cfg <<EOF
# UI ${UI}
# TIMEOUT 60
# label ${DemoRoot}
#     menu label ${DemoRoot}
#     KERNEL vmlinuz
#     INITRD initrd
#     APPEND root=CDLABEL=${DemoRoot} rootfstype=iso9660 ro
# EOF

genisoimage -no-emul-boot -boot-info-table -boot-load-size 4 \
            -o ${DemoRoot}.iso -b isolinux/isolinux.bin -c isolinux/boot.cat \
            -V ${DemoRoot} ${DemoRoot} # iso 74M

# isolinux.cfg没有`initrd=initrd`时报错:"end  Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(0,0)", 即没有根fs.
# isolinux.cfg有`initrd=initrd`且qemu-system-x86_64没有`-m`时, qemu花屏, qemu-system-x86_64设置`-m 256`后不花屏, 但报错"end  Kernel panic - not syncing: System is deadlocked on memory"，应该是内存不足导致, 将`-ｍ`设为512后报其他错误.
# isolinux.cfg有`initrd=initrd`且qemu-system-x86_64有`-m 512`时, 报错"blk_update_request: I/O error, dev fd0 ..." + "no arrays found in config file or automatically" + "/dev/ram0 does not exist. Dropping to a shell!", 但最终进入了initramfs, 且能正常执行`uname -a`
qemu-system-x86_64 -M pc -cdrom ${DemoRoot}.iso -enable-kvm -m 512 -boot d

echo -e "--- done isolinux-basic.sh ---\n\n"