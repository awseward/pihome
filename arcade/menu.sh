#!/bin/bash
# Menu for MAME machine
# Andrew Seward 2012
# Based on /usr/bin/raspi-config

######
#
# init stuff
#
######

# create array of roms
GAMES=$(ls /home/pi/.advance/rom/ | sed -e 's/\.[a-z]*//' | sed -e 's/bios//')
GAMESARRAY=($GAMES)

NEOGEO=$(ls /home/pi/.gngeo/rom/ | sed -e 's/\.[a-z]*//')
NEOGEOARRAY=($NEOGEO)

# create array of descriptions
OLD_IFS=$IFS
IFS=$'\n'
HUMANTITLES=( $(cat "/home/pi/arcade/humantitles.txt") )
IFS=$OLD_IFS

# create aggregate array to feed to whiptail
CHOICES=()
for((i=0; i<${#GAMESARRAY[@]}; i++))
do
  CHOICES+=("$i" "${HUMANTITLES[$i]}")
done
CHOICES+=("999" "System shut down") # Add a shutdown option

######
#
# functions
#
######

function launch {
  echo LAUNCHING ADVMAME
  advmame ${GAMESARRAY[$1]}
}

function launch_neo {
  echo LAUNCHING GNGEO
  gngeo ${GAMESARRAY[$1]}
  #gngeo ${NEOGEOARRAY[$1]}
}

function finish {
  clear
  exit 0
}

function turn_off {
  whiptail --infobox "The system will shut down now...\n\n Please don't forget to flip the power switch once it finishes shutting down, like back on 90s computers..." 10 60 1
  sleep 3; clear
  sudo shutdown -h now
  finish
}

######
#
# run loop
#
######
while true; do
  CHOICE=$(whiptail --menu "\n Select a Game" 40 80 30 --cancel-button Info --ok-button Select \
    "${CHOICES[@]}" \
    3>&1 1>&2 2>&3)
  RET=$?
  if [ $RET -eq 1 ]; then
    finish
  elif [ $RET -eq 0 ]; then
    if [ $CHOICE -eq 999 ]; then
      turn_off
    else
      launch_neo $CHOICE || launch $CHOICE || whiptail --msgbox "There was an error launching ${HUMANTITLES[$CHOICE]}" 20 60 1
    fi
  elif [ $TERM != "linux" ]; then
    clear
    exit 1
  else
    whiptail --infobox "I'm afraid I can't let you do that, Dave..." --title "HAL9000" 20 60 1
    sleep 3
  fi
done
