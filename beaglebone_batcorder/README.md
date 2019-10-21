## Hardware
This script is written for a beaglebone black, connected through USB to the batcorder. The USB connection should be powered externally, since the beaglebone cannot supply enough power on its own. You can do this by connecting an externally powered USB hub to the beaglebone, and connecting the batcorder the the USB hub.
- (GSM) batcorder
- Beaglebone black (possibly works with Raspberry Pi - not tested)
- Externally powered USB hub
- Wired internet connection

## How to use it
Written in bash, this script should be run from a terminal. Developed for Debian, but should work fine on other linux distributions. Should be run as sudoer.

Two options:
1. sudo bash dailyFTP.sh
2. sudo bash dailyFTP.sh -d

It works as follows:
- Beaglebone SD card and batcorder SD card are mounted
- Beaglebone SD card is synced to batcorder SD card
- Beaglebone SD card is transferred to our FTP server using lftp
- Beaglebone SD card and batcorder Sd card are unmounted
- If '-d' option is used (option 2), it will delete all data from the Beaglebone SD card, and relabel the batcorder SD-card to 'DELETEME', which will cause the batcorder to erase its SD card on the next boot. Any other way of erasing data off the batcorder SD card will cause the batcorder to raise an error and block further operation. When '-d' option was called, the data should be offloaded immediately! Failing to do so will result in the 'LOGFILE.TXT' file to be overwritten.
- If '-d' option is not used, it will simply backup the batcorder SD card to the beaglebone SD card and the FTP server.

## How to get it working
The script depends on the following packages:
- rsync
- lftp
- mlabel

We used crontab for scheduling a daily run of the script (without '-d'). When the batcorder SD card was almost full, the script was run with '-d' option.

For our setup, using a static IP address was required. This can be configured in the /etc/network/interfaces file, the following lines should be present:
```bash
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address your.ip.address.here
    netmask 255.255.255.0
    gateway 192.168.1.1

iface usb0 inet static
    address 192.168.7.2
    netmask 255.255.255.252
    network 192.168.7.0
    gateway 192.168.7.1
```

In addition, DHCP should be suppressed in the /etc/dhcp/dhclient.conf file. Add/uncomment/edit the following:
```bash
alias {
  interface "eth0";
  fixed-address your.ip.adress.here;
  option subnet-mask 255.255.255.0;
}
```
