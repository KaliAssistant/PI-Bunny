#!/usr/bin/bash

# Author: KaliAssistant
# Github: https://github.com/KaliAssistant


set -e

Color_Off='\033[0m'       # Text Reset
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

if [ "$EUID" -ne 0 ]
  then echo -e "${Red}[E] ${Color_Off}Please run as ${Red}root${Color_Off}"
  exit
fi

update_apt_and_install()
{
  echo -e "${Green}[I] ${Color_Off}Running apt update..."
  apt update -y && apt full-upgrade -y
  echo -e "${Green}[I] ${Color_Off}Installing packages..."
  xargs -a ./packages_list.txt apt install -y

}

install_tools_kali()
{
  if [ ! -d /home/kali/tools ]
  then
    echo -e "${Green}[I] ${Color_Off}Installing tools from github..."
    cp -R ../src/tools /home/kali/
    git clone "https://github.com/lgandx/Responder.git" /home/kali/tools/Responder
    git clone "https://github.com/ECTO-1A/AppleJuice.git" /home/kali/tools/AppleJuice
  else
    echo -e "${Red}[E] ${Color_Off}File ${Cyan}/home/kali/tools${Color_Off} exitst. Please remove it."
    exit 1
  fi 
}

install_files_root()
{
  if [ ! -d /root/bin ]
  then
    echo -e "${Green}[I] ${Color_Off}Linking bin files to ${Cyan}/usr/local/bin${Color_Off} ..."
    cp -R ../src/bin /root/bin/
    ln -sf /root/bin/ATTACKMODE     /usr/local/bin/ATTACKMODE
    ln -sf /root/bin/SYNC_LOOT      /usr/local/bin/SYNC_LOOT
    ln -sf /root/bin/SYNC_UDISK     /usr/local/bin/SYNC_UDISK
    ln -sf /root/bin/SYNC_PAYLOADS  /usr/local/bin/SYNC_PAYLOADS
    ln -sf /root/bin/PYQUACK        /usr/local/bin/PYQUACK
  else
    echo -e "${Red}[E] ${Color_Off}File ${Cyan}/root/bin${Color_Off} exitst. Please remove it."
    exit 1
  fi
  [ ! -d /root/payloads ] && mkdir /root/payloads
  [ ! -d /root/loot ] && mkdir /root/loot
  [ ! -d /root/udisk ] && mkdir /root/udisk
  [ ! -d /root/attackfs ] && mkdir /root/attackfs

  if [ ! -d /root/storage ]
  then
    echo -e "${Green}[I] ${Color_Off}Making the USB images..."
    truncate --size=1G /root/storage/udisk.img
    truncate --size=200M /root/storage/attackfs.img
    dd if=/dev/zero of=/root/storage/udisk.img bs=1024k count=1024 status=progress
    dd if=/dev/zero of=/root/storage/attackfs.img bs=1024k count=210 status=progress
    mkfs.vfat /root/storage/udisk.img -n "PIBUNNY"
    mkfs.vfat /root/storage/attackfs.img -n "DATA"
    mkdir /root/storage/udisk.d
    mkdir /root/storage/attackfs.d
    mount /root/storage/udisk.img /root/udisk
    mkdir /root/udisk/loot
    mkdir /root/udisk/payloads
    mkdir /root/udisk/attackFS
    umount -f /root/storage/udisk.img
  else
    echo -e "${Red}[E] ${Color_Off}File ${Cyan}/root/storage${Color_Off} exitst. Please remove it."
    exit 1
  fi
}

python_pip_install()
{
  echo -e "${Green}[I] ${Color_Off}Running pip install..."
  pip install -r ./requirements.txt
  pip install git+https://github.com/pybluez/pybluez.git#egg=pybluez
}

install_systemd_unit()
{
  echo -e "${Green}[I] ${Color_Off}Installing systemd unit services..."
  cp ../systemd/pi-tail* /etc/systemd/system/
  systemctl disable --now pi-tailms.service
  systemctl enable --now hciuart.service
  systemctl enable pi-tail-led.service
  systemctl enable pi-tail-on-switch-payloads.service
  systemctl enable pi-tail-switch.service
  systemctl enable pi-tail-sync.service
  systemctl enable pi-tail-led-off.service
}


echo -e "${Red}";
echo -e "    ____  ____     ____  __  ___   ___   ____  __";
echo -e "   / __ \/  _/    / __ )/ / / / | / / | / /\ \/ /";
echo -e "  / /_/ // /_____/ __  / / / /  |/ /  |/ /  \  / ";
echo -e " / ____// /_____/ /_/ / /_/ / /|  / /|  /   / /  ";
echo -e "/_/   /___/    /_____/\____/_/ |_/_/ |_/   /_/   ${Cyan} v1.0";
echo -e "                                                 ";
echo -e "${Color_Off}";


update_apt_and_install
install_tools_kali
install_files_root
python_pip_install
install_systemd_unit
echo -e "${Green}[I] ${Color_Off}Successfully installed PI-BUNNY. You should reboot the system rightnow."
