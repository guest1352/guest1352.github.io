#!/bin/sh
is_user_root () { [ "${EUID:-$(id -u)}" -eq 0 ]; }
if ! is_user_root; then
    echo "You need to run this as root!"
    exit 1
fi
echo "This needs to be run on Artix Linux with OpenRC!"
read -sp "Press enter to Continue"
# comment qemu command ↓ out later / remove it
if [ ! -e SeXfce_Theme.tar.xz ]; then
    pacman --noconfirm -S --needed wget
    wget http://xn--xp8hk1aaaaaaaa4f4c8frbb96cq78a.ml/sexlinux/SeXfce_Theme.tar.xz
fi

rm /home/monkey/artools-workspace/iso/base/*.iso
pacman --noconfirm -S --needed artools iso-profiles
umount -R /var/lib/artools/buildiso/base/artix/bootfs
umount -R /var/lib/artools/buildiso/base/artix/rootfs
modprobe loop
buildiso -p base -q
mkdir -p $HOME/.config/artools $HOME/artools-workspace
cp /etc/artools/artool*.conf $HOME/.config/artools/
cp -r /usr/share/artools/iso-profiles $HOME/artools-workspace/
buildiso -p base -x
sed -i 's|#rc_parallel="NO"|rc_parallel="YES"|' /var/lib/artools/buildiso/base/artix/rootfs/etc/rc.conf
cat > /var/lib/artools/buildiso/base/artix/rootfs/yPacmanScc << EOF
y
y
EOF
cp SeXfce_Theme.tar.xz /var/lib/artools/buildiso/base/artix/rootfs/usr/local/share/sexfce.tar.xz
cat > /var/lib/artools/buildiso/base/artix/rootfs/sexLinuxChrootScript.sh << EOF
#!/bin/sh
cat /yPacmanScc | pacman -Scc

pacman-key --init
pacman-key --populate artix
pacman-key --lsign-key 78C9C713EAD7BEC69087447332E21894258C6105
pacman --noconfirm -Syu --needed xfce4 sddm-openrc elogind librsvg
mkdir -p /etc/sddm.conf.d
echo "[Autologin]" > /etc/sddm.conf.d/autologin.conf
echo "User=artix" >> /etc/sddm.conf.d/autologin.conf
echo "Session=xfce" >> /etc/sddm.conf.d/autologin.conf
rc-update add sddm default
(cd /usr/local/share && tar -xf sexfce.tar.xz)

cat /yPacmanScc | pacman -Scc
EOF

while true; do
    read -p "Would you like to configure the System after making the Root File System? [y/n] " yn
    case $yn in
        [Yy]* ) echo "Configuring The System."; configAns="y" break;;
        [Nn]* ) echo "Not Configuring The System."; break;;
        * ) echo "Please answer yes or no.";;
    esac
done

chmod +x /var/lib/artools/buildiso/base/artix/rootfs/sexLinuxChrootScript.sh
artix-chroot /var/lib/artools/buildiso/base/artix/rootfs /sexLinuxChrootScript.sh
if [ "$configAns" = "y" ]; then
    artix-chroot /var/lib/artools/buildiso/base/artix/rootfs /bin/bash
fi
rm /var/lib/artools/buildiso/base/artix/rootfs/sexLinuxChrootScript.sh
rm /var/lib/artools/buildiso/base/artix/rootfs/yPacmanScc
rm /var/lib/artools/buildiso/base/artix/rootfs/usr/local/share/sexfce.tar.xz
buildiso -p base -sc
buildiso -p base -bc
sed -i 's|def_timezone="UTC"|def_timezone="Europe/Berlin"|' /var/lib/artools/buildiso/base/iso/boot/grub/defaults.cfg
sed -i 's|checksum=y|checksum=n|' /var/lib/artools/buildiso/base/iso/boot/grub/kernels.cfg
buildiso -p base -zc
# comment qemu command ↓ out later / remove it
qemu-system-x86_64 -m 4G -smp 6 -cpu host -enable-kvm -net nic -net user -cdrom /home/monkey/artools-workspace/iso/base/artix-base-openrc-$(date -Idate | sed -e s/-//g)-x86_64.iso