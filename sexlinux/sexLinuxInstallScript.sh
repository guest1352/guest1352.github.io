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
read -p "Press Enter to Start Installation"

# partitioning #

echo "Partition your Drive. When done close gparted."
gparted
lsblk
echo "Enter Partition and Mount point (ex. /dev/sda1 /boot) Type 'exit' when you're done"
while true; do
    read mpart
    case $mpart in
        /dev/*\ /* ) read -p "mount $(echo $mpart | awk '{print $1;}') at $(echo $mpart | awk '{print $2;}')?: " mconfirm; if [ "$mconfirm" = "y" ] || \
        [ "$mconfirm" = "Y" ] || [ "$mconfirm" = "yes" ] || [ "$mconfirm" = "Yes" ]; then mount -v \
        $(echo $mpart | awk '{print $1;}') /mnt$(echo $mpart | awk '{print $2;}'); else echo \
        "not mounting $(echo $mpart | awk '{print $1;}') at $(echo $mpart | awk '{print $2;}')"; fi;;
        [Ee]* ) echo "Done Partitioning and Mounting."; break;;
        * ) echo "Enter Partition and Mount point (ex. /dev/sda1 /boot) Type 'exit' when you're done";;
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
usermod -l $username -m -d /home/$username artix
groupmod -n $username artix
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
read -p "Disk to install Bootloader to (NOT PARTITION!): " DISKBOOT
grub-install --recheck \$DISKBOOT
grub-mkconfig -o /boot/grub/grub.cfg
userdel -r artix
EOF
chmod +x /mnt/sexLinuxChrootScript.sh
artix-chroot /mnt /sexLinuxChrootScript.sh
rm -f /mnt/home/$username/Desktop/installSexLinux.sh
# actually doing everything #
rm -f /mnt/sexLinuxChrootScript.shmnt/home/$username/Desktop/installSexLinux.sh
# actually doing everything #
rm -f /mnt/sexLinuxChrootScript.sh