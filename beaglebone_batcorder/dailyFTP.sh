#!/bin/bash
while getopts 'd' opt; do
case "$opt" in
d) flag=1 ;;
*) flag=0 ;;
esac
done

logs="/home/debian/logs"
logfile="${logs}/BBB2.log"
bbb_sd="/media/sd/"
bc_sd="/media/usb-drive/"
un="yourusernamehere"
pwd="yourpasswordnamehere"
ftp_server="yourftphere"
target_dir_files="yourlocationhere"
target_dir_logs="yourlocationhere"

echo >> $logfile # append empty line in log
echo "----------------------------------------"  >> $logfile
date >> $logfile # append date and time

mount -L GSM_BC $bc_sd &>> $logfile # mount the batcorder
mount /dev/mmcblk0p1 $bbb_sd # mount the BBB's SD card

rsync -av $bc_sd $bbb_sd &>> $logfile

#transfer files using FTP
if [ "$flag" = 1 ]; then
/usr/bin/lftp -e "set net:timeout 30; mirror --Remove-source-dirs -R ${bbb_sd} ${target_dir_files}; bye" -u $un,$pwd $ftp_server &>> $logfile
else
/usr/bin/lftp -e "set net:timeout 30; mirror -R ${bbb_sd} ${target_dir_files}; bye" -u $un,$pwd $ftp_server &>> $logfile
fi
/usr/bin/lftp -e "set net:timeout 30; mirror -R ${logs} ${target_dir_logs}; bye" -u $un,$pwd $ftp_server

umount /media/sd/
umount /media/usb-drive/

if [ "$flag" = 1 ]; then
echo "relabeling" >> $logfile
mlabel -i /dev/sda1 -s :: DELETEME
fi
