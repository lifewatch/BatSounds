# DailyFTP.sh

This script is written for a beaglebone black, connected through USB to the batcorder. It backs up all files on the batcorder to its own SD card, after which it will upload the files to an FTP server. Every step of the process is logged in BBB.log, a file that is also uploaded to the FTP server.

Using this script for your research or publication requires mentioning of Lifewatch Belgium, Flanders Marine Institute.

## Hardware
The USB connection should be powered externally, since the beaglebone cannot supply enough power on its own. You can do this by connecting an externally powered USB hub to the beaglebone, and connecting the batcorder the the USB hub.
- (GSM) batcorder and power supply
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
- If '-d' option is not used, it will simply back up the batcorder SD card to the beaglebone SD card and the FTP server.

## How to get it working
The script depends on the following packages:
- rsync
- lftp
- mlabel (part of mtools package)

We used crontab for scheduling a daily run of the script (without '-d'). When the batcorder SD card was almost full, the script was run with '-d' option.

For our setup, using a static IP address was required.
Two approaches can be used:
* Option 1: Set up connman by creating a file (`/var/lib/connman/eth0.config`)
and not touching the interfaces or dhclient file (both need to be cleared):
    ```code:bash
    [service_eth0]
    Type=ethernet
    IPv4=static.ip.addres.here/24/gateway.ip.address.here
    #IPv4=dhcp
    Nameservers=1.1.1.1
    ```
* Option 2: Alternately, this can be configured in the /etc/network/interfaces file. Three steps:
    - in /etc/network/interfaces the following lines should be present:
      ```code:bash
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
    - In addition, DHCP should be suppressed in the /etc/dhcp/dhclient.conf file. Add/uncomment/edit the following:
      ```code:bash
      alias {
      interface "eth0";
      fixed-address your.ip.adress.here;
      option subnet-mask 255.255.255.0;
      }
      ```
    - Disable connman, otherwise a DHCP request will be sent out on boot. In the terminal:
      ```code:bash
      systemctl disable connman.service 
      ```
