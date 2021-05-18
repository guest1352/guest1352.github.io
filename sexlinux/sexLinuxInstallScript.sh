#!/bin/sh

is_user_root () { [ "${EUID:-$(id -u)}" -eq 0 ]; }
if ! is_user_root; then
    echo "You need to run this as root!"
    exit 1
fi
read -p "Press Enter to Start Installation"

# partitioning #

echo "Partition your Drive. When done close gparted."
gparted
echo "Enter Partition and Mount point (ex. /dev/sda1 /boot) Type 'exit' when you're done"
while true; do
    read mpart
    case $mpart in
        /dev/*\ /* ) read -p "mount $(echo $mpart | awk '{print $1;}') at $(echo $mpart | awk '{print $2;}')?: " mconfirm; if [ "$mconfirm" = "y" ] || \
        [ "$mconfirm" = "Y" ] || [ "$mconfirm" = "yes" ] || [ "$mconfirm" = "Yes" ]; then mount \
        $(echo $mpart | awk '{print $1;}') $(echo $mpart | awk '{print $2;}'); else echo \
        "not mounting $(echo $mpart | awk '{print $1;}') at $(echo $mpart | awk '{print $2;}')"; fi;;
        [Ee]* ) echo "Done Partitioning and Mounting."; break;;
        * ) echo "Enter Partition and Mount point (ex. /dev/sda1 /boot) Type 'exit' when you're done";;
    esac
done

# partitioning #

# configuration (setting usernames and passwords and all that jazz) #

read -p "Set Username: " username
while true; do
    read -p "Set $username's Password: " usernamepassword
    read -p "Verify $username's Password: " usernamepasswordcheck
    if [ "$usernamepassword" = "$usernamepasswordcheck" ]; then
        break
    else
        echo "Passwords not the same! Try again."
    fi
done
while true; do
    read -p "Set root Password: " rootpassword
    read -p "Verify root Password: " rootpasswordcheck
    if [ "$rootpassword" = "$rootpasswordcheck" ]; then
        break
    else
        echo "Passwords not the same! Try again."
    fi
done
read -p "Set hostname: " inhostname

# configuration (setting usernames and passwords and all that jazz) #

# actually doing everything #

sudo cp -afv /* /mnt
echo "$inhostname" > /mnt/etc/hostname
echo "useradd -m $username" > /mnt/sexLinuxChrootScript.sh
echo "echo '$username:$usernamepasswordcheck' | chpasswd" >> /mnt/sexLinuxChrootScript.sh
echo "echo 'root:$rootpasswordcheck' | chpasswd" >> /mnt/sexLinuxChrootScript.sh
echo "cp -r /mnt/home/artix/* /mnt/home/$username/" >> /mnt/sexLinuxChrootScript.sh
echo "cp -r /mnt/home/artix/.* /mnt/home/$username/" >> /mnt/sexLinuxChrootScript.sh
cat >> /mnt/sexLinuxChrootScript.sh << EOF
lsblk
read -p "Disk to install Bootloader to (NOT PARTITION!): " DISKBOOT
grub-install --recheck $DISKBOOT
grub-mkconfig -o /boot/grub/grub.cfg
pacman --noconfirm -Rsn gparted
userdel -r artix
EOF
artix-chroot /mnt /sexLinuxChrootScript.sh

# actually doing everything #