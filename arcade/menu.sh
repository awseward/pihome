#!/bin/bash
# Menu for MAME machine
# Andrew Seward 2012
# Based on /usr/bin/raspi-config

######
#
# init stuff
#
######

if [ $1 -a $1 == "update" ]; then
  echo UPDATING GAMES...
  sleep 0.2

  # create arrays of advmame, gngeo roms
  ADVGAMES=$(ls /home/pi/.advance/rom/ | sed -e 's/\.[a-z]*//' | sed -e 's/bios//')
  ADVGAMESARRAY=($ADVGAMES)

  NEOGAMES=$(ls /home/pi/.gngeo/rom/ | sed -e 's/\.[a-z]*//' | sed -e 's/neogeo//')
  NEOGAMESARRAY=($NEOGAMES)

  # clear out /home/pi/arcade/common_roms/
  rm -f /home/pi/arcade/common_roms/*

  # repopulate it
  for game in "${ADVGAMESARRAY[@]}"
  do
    echo adding $game
    touch /home/pi/arcade/common_roms/$game
    sleep 0.01
  done
  
  for game in "${NEOGAMESARRAY[@]}"
  do
    echo adding $game
    touch /home/pi/arcade/common_roms/$game
    sleep 0.01
  done
fi

# create array of all games
ALLGAMES=$(ls /home/pi/arcade/common_roms/)
ALLGAMESARRAY=($ALLGAMES)

# create array of descriptions
OLD_IFS=$IFS
IFS=$'\n'
HUMANTITLES=( $(cat "/home/pi/arcade/humantitles.txt") )
IFS=$OLD_IFS

# create aggregate array to feed to whiptail
CHOICES=()
for((i=0; i<${#ALLGAMESARRAY[@]}; i++))
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
  if [ $( ls /home/pi/.advance/rom | grep -m 1 "${ALLGAMESARRAY[$1]}") ]; then
    advmame ${ALLGAMESARRAY[$1]}
  elif [ $( ls /home/pi/.gngeo/rom | grep -m 1 "${ALLGAMESARRAY[$1]}") ]; then
    gngeo ${ALLGAMESARRAY[$1]}
  fi
}

function error {
  whiptail --msgbox "There was an error launching ${HUMANTITLES[$1]}.\nLooks like you broke it..." 20 60 1
}

function exit_warning {
  whiptail --infobox "I'm afraid I can't let you do that, Dave...\n\nQuitting to the CLI without a keyboard may not be the best idea." --title "HAL9000" 20 60 1  
}

function finish {
  clear
  exit 0
}

function turn_off {
  whiptail --infobox "The system will shut down now...\n\nPlease don't forget to flip the power switch once it finishes shutting down, like back on 90s computers..." 10 60 1
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
  CHOICE=$(whiptail --menu "\n Select a Game" 30 80 20 --cancel-button Info --ok-button Select \
    "${CHOICES[@]}" \
    3>&1 1>&2 2>&3)
  RET=$?
  if [ $RET -eq 1 ]; then
    finish
  elif [ $RET -eq 0 ]; then
    if [ $CHOICE -eq 999 ]; then
      turn_off
    else
      launch $CHOICE || error $CHOICE
    fi
  elif [ $TERM != "linux" ]; then
    clear
    exit 1
  else
    exit_warning
    sleep 3
  fi
done
