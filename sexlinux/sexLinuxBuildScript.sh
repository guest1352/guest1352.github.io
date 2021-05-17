#!/bin/sh
is_user_root () { [ "${EUID:-$(id -u)}" -eq 0 ]; }
if ! is_user_root; then
    echo "You need to run this as root!"
    exit 1
fi
echo "This needs to be run on Artix Linux with OpenRC!"
read -sp "Press enter to Continue"
pacman --noconfirm -S --needed wget
wget -c http://xn--xp8hk1aaaaaaaa4f4c8frbb96cq78a.ml/sexlinux/SeXfce_Theme.tar.xz
wget -c http://xn--xp8hk1aaaaaaaa4f4c8frbb96cq78a.ml/sexlinux/SexConfig.tar.xz
wget -c http://xn--xp8hk1aaaaaaaa4f4c8frbb96cq78a.ml/sexlinux/pape.png
wget -c http://xn--xp8hk1aaaaaaaa4f4c8frbb96cq78a.ml/sexlinux/calamares.tar.xz
# comment rm iso command ↓ out later / remove it
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
mkdir -p /var/lib/artools/buildiso/base/artix/rootfs/home/artix
cp SexConfig.tar.xz /var/lib/artools/buildiso/base/artix/rootfs/home/artix/sexconfig.tar.xz
cp calamares.tar.xz /var/lib/artools/buildiso/base/artix/rootfs/calamares.tar.xz
cat > /var/lib/artools/buildiso/base/artix/rootfs/sexLinuxChrootScript.sh << EOF
#!/bin/sh
cat /yPacmanScc | pacman -Scc

pacman-key --init
pacman-key --populate artix
pacman-key --populate archlinux
pacman-key --lsign-key 78C9C713EAD7BEC69087447332E21894258C6105
pacman --noconfirm -Syu --needed xfce4 sddm-openrc elogind librsvg alacritty picom gnome-keyring fish fortune-mod lolcat firefox xorg-drivers mesa xfce4-whiskermenu-plugin networkmanager-openrc network-manager-applet calamares-branding
chsh -s /usr/bin/fish
echo "artix:artix" | chpasswd
su artix -c "echo 'artix' | chsh -s /usr/bin/fish"
mkdir -p /etc/sddm.conf.d
echo "[Autologin]" > /etc/sddm.conf.d/autologin.conf
echo "User=artix" >> /etc/sddm.conf.d/autologin.conf
echo "Session=xfce" >> /etc/sddm.conf.d/autologin.conf
rc-update add sddm default
rc-update add NetworkManager default
(cd /usr/local/share && tar -xf sexfce.tar.xz)
(cd /home/artix && tar -xf sexconfig.tar.xz)
(cd / && tar -xf calamares.tar.xz)
echo "sexlinux" > /etc/hostname

pacman --noconfirm -R xfce4-terminal
cat /yPacmanScc | pacman -Scc
EOF
cat > /var/lib/artools/buildiso/base/artix/rootfs/home/artix/.alacritty.yml << EOF
colors:
  primary:
    background: '0x282a36'
    foreground: '0xf8f8f2'
  cursor:
    text: CellBackground
    cursor: CellForeground
  vi_mode_cursor:
    text: CellBackground
    cursor: CellForeground
  search:
    matches:
      foreground: '0x44475a'
      background: '0x50fa7b'
    focused_match:
      foreground: '0x44475a'
      background: '0xffb86c'
    bar:
      background: '0x282a36'
      foreground: '0xf8f8f2'
  line_indicator:
    foreground: None
    background: None
  selection:
    text: CellForeground
    background: '0x44475a'
  normal:
    black:   '0x000000'
    red:     '0xff5555'
    green:   '0x50fa7b'
    yellow:  '0xf1fa8c'
    blue:    '0xbd93f9'
    magenta: '0xff79c6'
    cyan:    '0x8be9fd'
    white:   '0xbfbfbf'
  bright:
    black:   '0x4d4d4d'
    red:     '0xff6e67'
    green:   '0x5af78e'
    yellow:  '0xf4f99d'
    blue:    '0xcaa9fa'
    magenta: '0xff92d0'
    cyan:    '0x9aedfe'
    white:   '0xe6e6e6'
  dim:
    black:   '0x14151b'
    red:     '0xff2222'
    green:   '0x1ef956'
    yellow:  '0xebf85b'
    blue:    '0x4d5b86'
    magenta: '0xff46b0'
    cyan:    '0x59dffc'
    white:   '0xe6e6d1'
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
mkdir -p /var/lib/artools/buildiso/base/artix/rootfs/usr/share/backgrounds/sexlinux
cp pape.png /var/lib/artools/buildiso/base/artix/rootfs/usr/share/backgrounds/sexlinux/pape.png
artix-chroot /var/lib/artools/buildiso/base/artix/rootfs /sexLinuxChrootScript.sh
mkdir -p /var/lib/artools/buildiso/base/artix/rootfs/home/artix/.config/fish
mkdir -p /var/lib/artools/buildiso/base/artix/rootfs/root/.config/fish
cat > /var/lib/artools/buildiso/base/artix/rootfs/home/artix/.config/fish/config.fish << EOF
function fish_greeting
neofetch
fortune -o | lolcat
end
function bind_bang
    switch (commandline -t)[-1]
        case "!"
            commandline -t $history[1]; commandline -f repaint
        case "*"
            commandline -i !
    end
end

function bind_dollar
    switch (commandline -t)[-1]
        case "!"
            commandline -t ""
            commandline -f history-token-search-backward
        case "*"
            commandline -i '$'
    end
end

function fish_user_key_bindings
    bind ! bind_bang
    bind '$' bind_dollar
end
set EDITOR "nano"
EOF
cp /var/lib/artools/buildiso/base/artix/rootfs/home/artix/.config/fish/config.fish /var/lib/artools/buildiso/base/artix/rootfs/root/.config/fish/config.fish
if [ "$configAns" = "y" ]; then
    artix-chroot /var/lib/artools/buildiso/base/artix/rootfs /bin/bash
fi
rm /var/lib/artools/buildiso/base/artix/rootfs/sexLinuxChrootScript.sh
rm /var/lib/artools/buildiso/base/artix/rootfs/yPacmanScc
rm /var/lib/artools/buildiso/base/artix/rootfs/usr/local/share/sexfce.tar.xz
rm /var/lib/artools/buildiso/base/artix/rootfs/home/artix/sexconfig.tar.xz
rm /var/lib/artools/buildiso/base/artix/rootfs/calamares.tar.xz
buildiso -p base -sc
buildiso -p base -bc
sed -i 's|def_timezone="UTC"|def_timezone="Europe/Berlin"|' /var/lib/artools/buildiso/base/iso/boot/grub/defaults.cfg
sed -i 's|checksum=y|checksum=n|' /var/lib/artools/buildiso/base/iso/boot/grub/kernels.cfg
buildiso -p base -zc
# comment qemu command ↓ out later / remove it
qemu-system-x86_64 -m 4G -smp 6 -cpu host -enable-kvm -vga virtio -net nic -net user -cdrom /home/monkey/artools-workspace/iso/base/artix-base-openrc-$(date -Idate | sed -e s/-//g)-x86_64.iso