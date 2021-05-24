#!/bin/sh
setpass()
{
unset PASSWORD
unset CHARCOUNT
unset PROMPT
echo -n "$1"
stty -echo

CHARCOUNT=0
while IFS= read -p "$PROMPT" -r -s -n 1 CHAR
do
    # Enter - accept password
    if [[ $CHAR == $'\0' ]] ; then
        break
    fi
    # Backspace
    if [[ $CHAR == $'\177' ]] ; then
        if [ $CHARCOUNT -gt 0 ] ; then
            CHARCOUNT=$((CHARCOUNT-1))
            PROMPT=$'\b \b'
            PASSWORD="${PASSWORD%?}"
        else
            PROMPT=''
        fi
    else
        CHARCOUNT=$((CHARCOUNT+1))
        PROMPT='*'
        PASSWORD+="$CHAR"
    fi
done

stty echo
printf "\n"
export $2=$PASSWORD
}
is_user_root () { [ "${EUID:-$(id -u)}" -eq 0 ]; }
if ! is_user_root; then
    echo "You need to run this as root!"
    exit 1
fi
read -sp "Press Enter to Start Installation"

# partitioning #

printf "\n"
echo "Partition your Drive. When done close gparted."
gparted
lsblk
echo "Enter Partition and Mount point (ex. /dev/sda1 /) Type 'exit' when you're done"
echo "IMPORTANT: IF YOU MOUNT /boot , /home , /usr etc. BEFORE MOUNTING THE ROOT PARTITION THEY WILL NOT BE WRITTEN TO!"
while true; do
    read mpart
    case $mpart in
        /dev/*\ /* ) read -p "mount $(echo $mpart | awk '{print $1;}') at $(echo $mpart | awk '{print $2;}')?: " mconfirm; if [ "$mconfirm" = "y" ] || \
        [ "$mconfirm" = "Y" ] || [ "$mconfirm" = "yes" ] || [ "$mconfirm" = "Yes" ]; then mkdir -p /mnt$(echo $mpart | awk '{print $2;}') && mount -v \
        $(echo $mpart | awk '{print $1;}') /mnt$(echo $mpart | awk '{print $2;}'); else echo \
        "not mounting $(echo $mpart | awk '{print $1;}') at $(echo $mpart | awk '{print $2;}')"; fi;;
        [Ee]* ) echo "Done Partitioning and Mounting."; break;;
        * ) echo "Enter Partition and Mount point (ex. /dev/sda1 /) Type 'exit' when you're done";;
    esac
done

# partitioning #

# configuration (setting usernames and passwords and all that jazz) #

read -p "Set Username: " username
# make this check if there are any s p a c e s or CAPITALS in the username
echo 
while true; do
    setpass "Set $username's Password: " "usernamepassword"
    echo
    setpass "Verify $username's Password: " "usernamepasswordcheck"
    echo
    if [ "$usernamepassword" = "$usernamepasswordcheck" ]; then
        break
    else
        echo "Passwords not the same! Try again."
        echo
    fi
done
while true; do
    setpass "Set root Password: " "rootpassword"
    echo
    setpass "Verify root Password: " "rootpasswordcheck"
    echo
    if [ "$rootpassword" = "$rootpasswordcheck" ]; then
        break
    else
        echo "Passwords not the same! Try again."
        echo
    fi
done
read -p "Set hostname: " inhostname

# configuration (setting usernames and passwords and all that jazz) #

# actually doing everything #
shopt -s extglob
cp -avfx / /mnt/
echo "$inhostname" > /mnt/etc/hostname
echo "127.0.0.1 localhost" > /mnt/etc/hosts
echo "::1 localhost" >> /mnt/etc/hosts
echo "127.0.1.1 $inhostname.localdomain $inhostname" >> /mnt/etc/hosts
rm -f /mnt/etc/sddm.conf.d/autologin.conf
cp -vaT /run/artix/bootmnt/boot/vmlinuz-$(uname -m) /mnt/boot/vmlinuz-linux
rm /mnt/etc/fstab
fstabgen -U /mnt >> /mnt/etc/fstab
cat > /mnt/sexLinuxChrootScript.sh << EOF
#!/bin/sh
usermod -l $username -d /home/$username -m sex
groupmod -n $username sex
rm -rf /home/$username/.cache/sessions/
echo '$username:$usernamepasswordcheck' | chpasswd
echo 'root:$rootpasswordcheck' | chpasswd
pacman --noconfirm -Rsn gparted
pacman --noconfirm -R artix-branding-base artix-live-openrc artix-live-base
rc-update del artix-live
rm /etc/issue
touch /etc/issue
rm -f /boot/amd-ucode.img /boot/intel-ucode.img
mkinitcpio -P
lsblk
while true; do
    read -p "Are you on BIOS or UEFI?: " bu
    case \$bu in
        [Bb]* ) read -p "Disk to install Bootloader to (NOT PARTITION!): " DISKBOOT; grub-install --recheck \$DISKBOOT; break;;
        [Uu]* ) read -p "Enter EFI partition mount point (most likely /boot): " EFIPART; grub-install --target=x86_64-efi --efi-directory=\$EFIPART --bootloader-id=SEX; break;;
        * ) echo "Please answer BIOS or UEFI.";;
    esac
done
grub-mkconfig -o /boot/grub/grub.cfg
userdel -r sex
userdel -r artix
rm -rf /home/artix
sed -i '/echo -e/d' /home/$username/.config/fish/config.fish
sed -i '/echo -e/d' /root/.config/fish/config.fish
sed -i 's|:NOPASSWD||' /etc/sudoers.d/g_wheel
pacman-key --init
pacman-key --populate artix
pacman-key --populate archlinux
pacman-key --lsign-key 78C9C713EAD7BEC69087447332E21894258C6105
EOF
chmod +x /mnt/sexLinuxChrootScript.sh
artix-chroot /mnt /sexLinuxChrootScript.sh
# actually doing everything #

# cleaning up #
rm -f /mnt/home/$username/Desktop/.installSexLinux.sh /mnt/sexLinuxChrootScript.sh /mnt/home/$username/Desktop/'Install Sex Linux.desktop'
# cleaning up #
read -p "Installer finished! you can now reboot or continue exploring Sex Linux. "