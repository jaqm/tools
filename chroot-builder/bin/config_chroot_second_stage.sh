#!/bin/bash

#############################################################
# Author: Jose Antonio Quevedo <joseantonio.quevedo@gmail.com>
# Date: 2013-2014
#
# Based on: http://linux-sunxi.org/Debian
#
# NOTE: This script will be run whithin the chroot AS ROOT!
#############################################################

#set -x

INIT_PWD=$(pwd)

cd $(dirname $0)
BASEDIR=$(pwd)

##################################
#VARIABLES

#CHROOT_NAME=$
myHostName=myChroot

## FUNCIONES

function configSourcesList(){

#cat <<EOF
#END > /etc/apt/sources.list
echo "deb http://ftp.us.debian.org/debian/ sid main contrib non-free
deb-src http://ftp.us.debian.org/debian/ sid main contrib non-free
#deb http://ftp.us.debian.org/debian/ wheezy-updates main contrib non-free
#deb-src http://ftp.us.debian.org/debian/ wheezy-updates main contrib non-free
#deb http://security.debian.org/ wheezy/updates main contrib non-free
#deb-src http://security.debian.org/ wheezy/updates main contrib non-free"\
>> /etc/apt/sources.list
#END
#EOF

apt-get update
}

function configLanguage(){

  ## Language
    export LANG=C

    dpkg-reconfigure locales
# Choose en_US.UTF-8 for both prompts, or whatever you want.
    export LANG=en_US.UTF-8


}

function configKeyboard(){

    dpkg-reconfigure keyboard-configuration -phigh

}

function installDeps(){

    MIN_DEPS="netbase"
    SYSTEM_DEPS="udev"
    NETWORKING_DEPS="ifupdown net-tools iproute iputils-ping ntpdate ntp dhcp3-client"
    APT_DEPS="apt-utils dialog"
    KEYBOARD_DEPS="keyboard-configuration"
    NET_TOOLS="wget"
    SYSTEM_TOOLS="mc"
    OPTIONAL_DEPS="git"
    OSSEC_DEPS="expect libc6"
    SERVICES_DEPS="dropbear"
    NOT_NEEDED_DEPS="dialog locales vim nano less tzdata console-tools module-init-tools"

    apt-get update

    apt-get install $MIN_DEPS $SYSTEM_DEPS $NETWORKING_DEPS $APT_DEPS $KEYBOARD_DEPS $NET_TOOLS $SYSTEM_TOOLS $OPTIONAL_DEPS #$SERVICES_DEPS $NOT_NEEDED_DEPS 

}

function configNetwork(){

# Configure Network
#    cat <<EOF
#END > /etc/network/interfaces
echo "auto lo eth0
allow-hotplug eth0
iface lo inet loopback
iface eth0 inet dhcp" \
> /etc/network/interfaces
#END

#EOF


}

function setHostname(){
    echo $myHostName > /etc/hostname
}

function configFilesystem(){

    cat <<EOF
END > /etc/fstab
# /etc/fstab: static file system information.
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
/dev/root      /               ext4    noatime,errors=remount-ro 0 1
tmpfs          /tmp            tmpfs   defaults          0       0
END
EOF

}

function activateRemoteconsole(){

## Activate remote console
    echo 'T0:2345:respawn:/sbin/getty -L ttyS0 115200 linux' >> /etc/inittab
    sed -i 's/^\([3-6]:.* tty[3-6]\)/#\1/' /etc/inittab

}

function configureChroot(){

    configSourcesList
    installDeps

#    configLanguage
    configKeyboard

    configNetwork
    setHostname

    ## Config Filesystem
    configFilesystem
    activateRemoteconsole


    ## Set root passwd
    passwd
    exit

}


#main(){

configureChroot

#}

