#!/bin/bash

# UUID's to backup (separate with space)
# Format:  name:id
# Example: galaxy_ext_sd:3161-3632
BACKUPS="galaxy_ext_sd:3161-3632 galaxy_int_sd:E5F3-0F04 defy_sd:3765-3561"
TARGET="/mnt/nas/BACKUP/USB"

SIZE=$1
BG=$2
# Are we running detached?
if [ $BG = 1 ]; then
    env > /tmp/usbbackup_$ID_FS_UUID_ENC.env
    if [ $DISK_MEDIA_CHANGE = 1 ] && [ $SIZE -gt 0 ]; then
	for bak in $BACKUPS; do
	    name=$(echo $bak|awk -F: '{print $1}')
	    uuid=$(echo $bak|awk -F: '{print $2}')
    	    # check for a matching uuid
	    if [ "$uuid" = "$ID_FS_UUID_ENC" ]; then
		logger -t usbbackup "Starting backup of disk $uuid ($DEVNAME) to $TARGET/$name"
		if [ ! -d /tmp/$uuid ]; then
		    mkdir /tmp/$uuid
		fi
		mount $DEVNAME /tmp/$uuid
		rsync --progress -av --exclude=.thumbnails /tmp/$uuid/DCIM $TARGET/$name > /tmp/rsync.$uuid.log
		rsync --progress -av /tmp/$uuid/Movies $TARGET/$name >> /tmp/rsync.$uuid.log
		umount /tmp/$uuid
		logger -t usbbackup "Finished backup of disk $uuid ($DEVNAME) to $TARGET/$name"
	    fi
	done
    fi
else
    $0 $SIZE 1 &
fi
