#!/bin/bash
while getopts 'd' opt; do                 # check if remove flag -d is there
case "$opt" in
d) flag=1 ;;
*) flag=0 ;;
esac
done

logs="/home/debian/logs"                  # location of the logfile
logfile="${logs}/BBB.log"                 # name of the logfile
bbb_sd="/media/sd/"                       # mountpoint for the beaglebone SD card
bc_sd="/media/usb-drive/"                 # mountpoint for the batcorder
un="yourusernamehere"                     # your ftp login username
pwd="yourpasswordnamehere"                # your ftp login password
ftp_server="yourftphere"                  # your ftp server name
target_dir_files="yourlocationhere"       # location of the recordings on the ftp server
target_dir_logs="yourlocationhere"        # location of the logs on the ftp server

echo >> $logfile                          # append empty line in log
echo "----------------------------------------"  >> $logfile
date >> $logfile                          # append date and time

echo "mounting" >> $logfile
mount -L GSM_BC $bc_sd &>> $logfile       # mount the batcorder
mount /dev/mmcblk0p1 $bbb_sd              # mount the beaglebone SD card

echo "syncing" >> $logfile
rsync -av $bc_sd $bbb_sd &>> $logfile     # rsync the beaglebone SD card to the batcorder

echo "transferring" >> $logfile          #transfer files and logs using FTP
if [ "$flag" = 1 ]; then                  # clear beaglebone SD card
/usr/bin/lftp -e "set net:timeout 30; mirror --Remove-source-dirs -R ${bbb_sd} ${target_dir_files}; bye" -u $un,$pwd $ftp_server &>> $logfile
else
/usr/bin/lftp -e "set net:timeout 30; mirror -R ${bbb_sd} ${target_dir_files}; bye" -u $un,$pwd $ftp_server &>> $logfile
fi
/usr/bin/lftp -e "set net:timeout 30; mirror -R ${logs} ${target_dir_logs}; bye" -u $un,$pwd $ftp_server

echo "unmounting" >> $logfile
umount /media/sd/                         # unmount SD card
umount /media/usb-drive/                  # unmount batcorder

if [ "$flag" = 1 ]; then
echo "relabeling" >> $logfile
mlabel -i /dev/sda1 -s :: DELETEME        # relabel batcorder SD card to DELETEME for automatic clearing by the batcorder
fi
