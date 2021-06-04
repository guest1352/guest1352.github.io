#!/bin/sh
is_user_root () { [ "${EUID:-$(id -u)}" -eq 0 ]; }
if ! is_user_root; then
    echo "You need to run this as root"
    exit 1
fi
echo "This needs to be run on Artix Linux with OpenRC!"
read -sp "Press enter to Continue"
pacman --noconfirm -S --needed wget
wget -c http://xn--xp8hk1aaaaaaaa4f4c8frbb96cq78a.ml/sexlinux/SeXfce_Theme.tar.xz
wget -c http://xn--xp8hk1aaaaaaaa4f4c8frbb96cq78a.ml/sexlinux/SexConfig.tar.xz
wget -c http://xn--xp8hk1aaaaaaaa4f4c8frbb96cq78a.ml/sexlinux/pape.png
wget -c http://xn--xp8hk1aaaaaaaa4f4c8frbb96cq78a.ml/sexlinux/sexLinuxInstallScript.sh
wget -c http://xn--xp8hk1aaaaaaaa4f4c8frbb96cq78a.ml/stuff/donut
wget -c http://xn--xp8hk1aaaaaaaa4f4c8frbb96cq78a.ml/images/stuff/babunga.png
wget -c http://xn--xp8hk1aaaaaaaa4f4c8frbb96cq78a.ml/images/stuff/nigs.png
wget -c http://xn--xp8hk1aaaaaaaa4f4c8frbb96cq78a.ml/sexlinux/neofetch
# remove ↓ these lines
#rm /home/monkey/artools-workspace/iso/base/*.iso
#rm /home/monkey/shitsite/sexlinux/bruh.img
#qemu-img create -f qcow2 /home/monkey/shitsite/sexlinux/bruh.img 10G
# remove ^ these lines
pacman --noconfirm -S --needed artools iso-profiles
umount -R /var/lib/artools/buildiso/base/artix/bootfs
umount -R /var/lib/artools/buildiso/base/artix/rootfs
modprobe loop
buildiso -p base -q
mkdir -p $HOME/.config/artools $HOME/artools-workspace
cp /etc/artools/artools-*.conf $HOME/.config/artools/
cp -r /usr/share/artools/iso-profiles $HOME/artools-workspace/
buildiso -p base -x
sed -i 's|#rc_parallel="NO"|rc_parallel="YES"|' /var/lib/artools/buildiso/base/artix/rootfs/etc/rc.conf
cp SeXfce_Theme.tar.xz /var/lib/artools/buildiso/base/artix/rootfs/usr/local/share/sexfce.tar.xz
mkdir -p /var/lib/artools/buildiso/base/artix/rootfs/home/sex
cp SexConfig.tar.xz /var/lib/artools/buildiso/base/artix/rootfs/home/sex/sexconfig.tar.xz
rm /var/lib/artools/buildiso/base/artix/rootfs/etc/artix-release
rm /var/lib/artools/buildiso/base/artix/rootfs/usr/bin/neofetch
cp neofetch /var/lib/artools/buildiso/base/artix/rootfs/usr/bin/neofetch
chmod +x /var/lib/artools/buildiso/base/artix/rootfs/usr/bin/neofetch
echo "Sex Linux Release" > /var/lib/artools/buildiso/base/artix/rootfs/etc/sex-release
cat > /var/lib/artools/buildiso/base/artix/rootfs/etc/os-release << EOF
NAME="Sex Linux"
PRETTY_NAME="Sex Linux"
ID=sex
BUILD_ID=rolling
ANSI_COLOR="0;36"
HOME_URL="http://xn--xp8hk1aaaaaaaa4f4c8frbb96cq78a.ml/"
DOCUMENTATION_URL="http://xn--xp8hk1aaaaaaaa4f4c8frbb96cq78a.ml/"
SUPPORT_URL="http://xn--xp8hk1aaaaaaaa4f4c8frbb96cq78a.ml/"
BUG_REPORT_URL="http://xn--xp8hk1aaaaaaaa4f4c8frbb96cq78a.ml/"
LOGO=sexlinux
EOF
cat > /var/lib/artools/buildiso/base/artix/rootfs/etc/lsb-release << EOF
LSB_VERSION=4.20
DISTRIB_ID=Sex
DISTRIB_RELEASE=rolling
DISTRIB_DESCRIPTION="Sex Linux"
EOF
cat > /var/lib/artools/buildiso/base/artix/rootfs/sexLinuxChrootScript.sh << EOF
#!/bin/sh
printf y\ny\n | pacman -Scc

usermod -l sex -d /home/sex -m artix
groupmod -n sex artix
pacman-key --init
pacman-key --populate artix
pacman-key --populate archlinux
pacman-key --lsign-key 78C9C713EAD7BEC69087447332E21894258C6105
pacman --noconfirm -Syu --needed xfce4 gparted pulseaudio xfce4-pulseaudio-plugin pavucontrol pulseaudio-alsa sddm-openrc elogind librsvg alacritty picom gnome-keyring fish fortune-mod lolcat firefox xorg-drivers mesa xfce4-whiskermenu-plugin networkmanager-openrc network-manager-applet
chsh -s /usr/bin/fish
echo "sex:sex" | chpasswd
su sex -c "echo 'sex' | chsh -s /usr/bin/fish"
mkdir -p /etc/sddm.conf.d
echo "[Autologin]" > /etc/sddm.conf.d/autologin.conf
echo "User=sex" >> /etc/sddm.conf.d/autologin.conf
echo "Session=xfce" >> /etc/sddm.conf.d/autologin.conf
rc-update add sddm default
rc-update add NetworkManager default
(cd /usr/local/share && tar -xf sexfce.tar.xz)
(cd /home/sex && tar -xf sexconfig.tar.xz)
echo "sexlinux" > /etc/hostname
rm /home/sex/.config/neofetch/config.conf
rm /root/.config/neofetch/config.conf
userdel -r artix
rm -rf /home/artix
chown -v -R sex:sex /home/sex/

cat /yPacmanScc | pacman -Scc
EOF
mkdir -p /var/lib/artools/buildiso/base/artix/rootfs/home/sex/Desktop
cat > /var/lib/artools/buildiso/base/artix/rootfs/home/sex/Desktop/'Install Sex Linux.desktop' << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Install Sex Linux
Comment=Sex Linux Installer
Exec=sudo alacritty -e /home/sex/Desktop/.installSexLinux.sh --config-file /home/sex/.alacritty.yml
Icon=
Path=/home/sex/Desktop
Terminal=false
StartupNotify=false
EOF
chmod +x /var/lib/artools/buildiso/base/artix/rootfs/home/sex/Desktop/'Install Sex Linux.desktop'
cat > /var/lib/artools/buildiso/base/artix/rootfs/home/sex/.alacritty.yml << EOF
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
artix-chroot /var/lib/artools/buildiso/base/artix/rootfs /sexLinuxChrootScript.sh
mkdir -p /var/lib/artools/buildiso/base/artix/rootfs/usr/share/backgrounds/sexlinux
cp pape.png /var/lib/artools/buildiso/base/artix/rootfs/usr/share/backgrounds/sexlinux/pape.png
mkdir -p /var/lib/artools/buildiso/base/artix/rootfs/home/sex/.config/fish
mkdir -p /var/lib/artools/buildiso/base/artix/rootfs/root/.config/fish
cat > /var/lib/artools/buildiso/base/artix/rootfs/home/sex/.config/fish/config.fish << EOF
function fish_greeting
neofetch
fortune -o | lolcat
echo -e "\e[31mPASSWORD FOR USER 'sex' IS 'sex'\e[0m"
end
function bind_bang
    switch (commandline -t)[-1]
        case "!"
            commandline -t \$history[1]; commandline -f repaint
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
mkdir -p /var/lib/artools/buildiso/base/artix/rootfs/home/sex/Desktop
cp sexLinuxInstallScript.sh /var/lib/artools/buildiso/base/artix/rootfs/home/sex/Desktop/.installSexLinux.sh
cp donut /var/lib/artools/buildiso/base/artix/rootfs/usr/bin/donut
chmod +x /var/lib/artools/buildiso/base/artix/rootfs/usr/bin/donut
chmod +x /var/lib/artools/buildiso/base/artix/rootfs/home/sex/Desktop/.installSexLinux.sh
cp /var/lib/artools/buildiso/base/artix/rootfs/home/sex/.config/fish/config.fish /var/lib/artools/buildiso/base/artix/rootfs/root/.config/fish/config.fish
cp nigs.png /var/lib/artools/buildiso/base/artix/rootfs/usr/share/grub/themes/artix/background.png
cp babunga.png /var/lib/artools/buildiso/base/artix/rootfs/usr/share/grub/themes/artix/logo.png
if [ "$configAns" = "y" ]; then
    artix-chroot /var/lib/artools/buildiso/base/artix/rootfs /bin/bash
fi
rm /var/lib/artools/buildiso/base/artix/rootfs/sexLinuxChrootScript.sh
rm /var/lib/artools/buildiso/base/artix/rootfs/usr/local/share/sexfce.tar.xz
rm /var/lib/artools/buildiso/base/artix/rootfs/home/sex/sexconfig.tar.xz
buildiso -p base -sc
buildiso -p base -bc
sed -i 's|def_timezone="UTC"|def_timezone="Europe/Berlin"|' /var/lib/artools/buildiso/base/iso/boot/grub/defaults.cfg
sed -i 's|checksum=y|checksum=n|' /var/lib/artools/buildiso/base/iso/boot/grub/kernels.cfg
cp nigs.png /var/lib/artools/buildiso/base/iso/boot/grub/themes/artix/background.png
cp babunga.png /var/lib/artools/buildiso/base/iso/boot/grub/themes/artix/logo.png
buildiso -p base -zc
# comment qemu command ↓ out later / remove it
#qemu-system-x86_64 -m 4G -smp 6 -cpu host -enable-kvm -bios /usr/share/edk2-ovmf/x64/OVMF_CODE.fd -vga virtio -net nic -net user -cdrom /home/monkey/artools-workspace/iso/base/artix-base-openrc-$(date -Idate | sed -e s/-//g)-x86_64.iso -hda bruh.img  -device ich9-intel-hda,addr=1f.1 -audiodev pa,id=snd0 -device hda-output,audiodev=snd0
