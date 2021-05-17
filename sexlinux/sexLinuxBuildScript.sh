#!/bin/sh
is_user_root () { [ "${EUID:-$(id -u)}" -eq 0 ]; }
if ! is_user_root; then
    echo "You need to run this as root!"
    exit 1
fi
echo "This script needs pacman, only tested on Artix Linux with openrc. Might break on other distros!"
read -sp "Press enter to Continue"
pacman --noconfirm -S --needed artools iso-profiles
modprobe loop
buildiso -p base -q
cp /etc/artools/artool*.conf ~/.config/artools
cp -r /usr/share/artools/iso-profiles ~/artools-workspace/
buildiso -p base -x
sed -i 's|#rc_parallel="NO"|rc_parallel="YES"|' /var/lib/artools/buildiso/base/artix/rootfs/etc/rc.conf
cat > /var/lib/artools/buildiso/base/artix/rootfs/sexLinuxChrootScript.sh << EOF
#!/bin/sh
echo y\ny | pacman -Scc
pacman-key --init
pacman-key --populate artix
pacman-key --lsign-key 78C9C713EAD7BEC69087447332E21894258C6105
pacman --noconfirm -Syu xfce4 sddm-openrc elogind
mkdir -p /etc/sddm.conf.d
echo "[Autologin]" > /etc/sddm.conf.d/autologin.conf
echo "User=artix" >> /etc/sddm.conf.d/autologin.conf
echo "Session=xfce" >> /etc/sddm.conf.d/autologin.conf
echo y\ny | pacman -Scc
exit
EOF
chmod +x /var/lib/artools/buildiso/base/artix/rootfs/sexLinuxChrootScript.sh
artix-chroot /var/lib/artools/buildiso/base/artix/rootfs /sexLinuxChrootScript.sh
rm /var/lib/artools/buildiso/base/artix/rootfs/sexLinuxChrootScript.sh
buildiso -p base -sc
buildiso -p base -bc
sed -i 's|def_timezone="UTC"|def_timezone="Europe/Berlin"|' /var/lib/artools/buildiso/base/iso/boot/grub/defaults.cfg
sed -i 's|checksum=y|checksum=n|' /var/lib/artools/buildiso/base/iso/boot/grub/kernels.cfg
buildiso -p base -zc
# comment qemu command ↓ out later / remove it
qemu-system-x86_64 -m 4G -smp 6 -cpu host -enable-kvm -net nic -net user -cdrom ~/artools-workspace/iso/base/artix-base-openrc-$(date -Idate | sed -e s/-//g)-x86_64.iso