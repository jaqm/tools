#!/bin/bash

# Author: Jose Antonio Quevedo <joseantonio.quevedo@gmail.com>
# Date: 2013-2014

# Based on: http://linux-sunxi.org/Debian

#set -x 
set -e

INIT_PWD=$(pwd)

cd $(dirname $0)
BASEDIR=$(pwd)

##################################

## ARGUMENTOS
ARCH=$1

#VARIABLES
CHROOT_NAME=binary
TEST_DIR=chroot
IMAGE_FILE_EXT=ext4

SECOND_STAGE_SCRIPT_FILENAME=config_chroot_second_stage.sh
SECOND_STAGE_SCRIPT=$BASEDIR/bin/$SECOND_STAGE_SCRIPT_FILENAME
DEST_SECOND_STAGE_FILENAME_CHROOT=/usr/bin/$SECOND_STAGE_SCRIPT_FILENAME
DEST_SECOND_STAGE_FILE=$BASEDIR/$TEST_DIR/$CHROOT_NAME/$DEST_SECOND_STAGE_FILENAME_CHROOT


## FUNCTIONS

function parada(){
    echo "Parada de segundos.."
    sleep 10

}

function buildDebootstrap(){

    DEBOOTSTRAP_ARCH=$1
    [ -z $DEBOOTSTRAP_ARCH ] && DEBOOTSTRAP_ARCH=armhf

    mkdir $TEST_DIR || true

    cd $TEST_DIR

    mkdir $CHROOT_NAME || true

    OUTPUT_IMAGE=$CHROOT_NAME.$IMAGE_FILE_EXT
    [ -e $OUTPUT_IMAGE ] || (
    	dd if=/dev/zero of=$OUTPUT_IMAGE bs=1M count=2048
	/sbin/mkfs.ext4 -F $OUTPUT_IMAGE
    )
    sudo mount -o loop $OUTPUT_IMAGE $CHROOT_NAME || true


#    [ -d $CHROOT_NAME/debootsrap -o -d $CHROOT_NAME/usr/ ] ||
    [ -e $CHROOT_NAME/debootstrap/debootstrap ] || (
	sudo debootstrap --verbose --download-only --arch $DEBOOTSTRAP_ARCH --variant=minbase --foreign sid $CHROOT_NAME http://ftp.es.debian.org/debian
	sudo debootstrap --verbose --arch $DEBOOTSTRAP_ARCH --variant=minbase --foreign sid $CHROOT_NAME http://ftp.es.debian.org/debian || true
    )
#    parada

    sudo mkdir -p $CHROOT_NAME/dev/pts | true
    sudo mkdir -p $CHROOT_NAME/proc || true
    sudo modprobe binfmt_misc
    sudo mount -t devpts devpts $CHROOT_NAME/dev/pts || true
    sudo mount -t proc proc $CHROOT_NAME/proc || true


}

function copySecondStage2chroot(){
    sudo cp $SECOND_STAGE_SCRIPT $DEST_SECOND_STAGE_FILE
    sudo chmod 755 $DEST_SECOND_STAGE_FILE
    sudo chown root:root $DEST_SECOND_STAGE_FILE
}


# main(){

# installDeps
#sudo aptitude install debootstrap qemu-user-static binfmt-support

buildDebootstrap $ARCH

echo " At the end, you should see \"I: Base system installed successfully.\""

parada
copySecondStage2chroot

# Compatibilidad arm
[ $ARCH == armhf ] && sudo cp /usr/bin/qemu-arm-static $CHROOT_NAME/usr/bin/

#parada
echo "DEBOOTSTRAP SECOND-STAGE:"
sudo chroot $CHROOT_NAME /debootstrap/debootstrap --second-stage

#parada
echo "CUSTOMIZING CHROOT:"
sudo chroot $CHROOT_NAME $DEST_SECOND_STAGE_FILENAME_CHROOT

#echo "Comprimiendo chroot en $CHROOT_NAME.tar.gz"
#sudo tar -czf $CHROOT_NAME.tar.gz $CHROOT_NAME


#exit 

# echo
# echo "Take a look at: http://linux-sunxi.org/FirstSteps"
# echo "to build u-boot, kernel, script.bin and boot.cmd."
# echo

#}


