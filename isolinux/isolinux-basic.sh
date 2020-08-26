#!/usr/bin/env bash
set -e
#set -x

echo -e "--- start isolinux-basic.sh ---\n\n"
# https://www.chengweiyang.cn/2011/08/13/create-linux-system-iso/
# https://www.codenong.com/cs105923217/
# https://wiki.gentoo.org/wiki/Syslinux

SyslinuxRoot=../syslinux-root
DemoRoot=isolinux-basic

mkdir -pv ${DemoRoot}
rm -rf ${DemoRoot}/isolinux || true
mkdir -pv ${DemoRoot}/isolinux

UI='vesamenu.c32'
# UI='menu.c32'

cp ${SyslinuxRoot}/bios/core/isolinux.bin ${DemoRoot}/isolinux
cp ${SyslinuxRoot}/bios/com32/elflink/ldlinux/ldlinux.c32 ${DemoRoot}/isolinux
cp ${SyslinuxRoot}/bios/com32/libutil/libutil.c32 ${DemoRoot}/isolinux
if [ $UI = 'vesamenu.c32' ]; then
    cp ${SyslinuxRoot}/bios/com32/lib/libcom32.c32 ${DemoRoot}/isolinux
    cp ${SyslinuxRoot}/bios/com32/menu/vesamenu.c32 ${DemoRoot}/isolinux
else
    cp ${SyslinuxRoot}/bios/com32/menu/menu.c32 ${DemoRoot}/isolinux
fi

cat > ${DemoRoot}/isolinux/isolinux.cfg <<EOF
UI ${UI}
label isolinux-demo
    menu label isolinux-demo
EOF

genisoimage -no-emul-boot -boot-info-table -boot-load-size 4 \
            -o ${DemoRoot}.iso -b isolinux/isolinux.bin -c isolinux/boot.cat \
            ${DemoRoot}

# 从光盘启动，并且显示了isolinux的启动菜单. 选择启动后会发现系统不能启动，这是因为没有可以启动的系统内核
qemu-system-x86_64 -M pc -cdrom ${DemoRoot}.iso -boot d

echo -e "--- done isolinux-basic.sh ---\n\n"