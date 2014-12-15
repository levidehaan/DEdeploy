#!/bin/bash

INPUT=/tmp/menu.sh.$$

OUTPUT=output.log
touch $OUTPUT

vi_editor=${EDITOR-vi}

trap "rm $OUTPUT; rm $INPUT; exit" SIGHUP SIGINT SIGTERM

function createPXEbooter(){

    dialog --backtitle "Starting docker build!"\
     --title "Installing......" --clear\
      --infobox "Setting up your pxe installer :)" 40 90

    sudo docker build -t pxeinstaller dockerfiles/pxebooter 2>&1 | tee -a output.log

    sudo umount dockerfiles/pxebooter/isomount 2>&1 | tee -a output.log

	dialog --backtitle "PXE Booter Install COMPLETED!!"\
	 --title "Finished Install!" --clear\
	 --msgbox "$(cat output.log)" 40 90

}

function downloadUbuntuServer(){

    dialog --backtitle "downloading ubuntu 14.04.1 server image"\
     --title "Downloading......" --clear\
      --infobox "Downloading Ubuntu Server, this could take a long time... :)" 40 90

    wget http://mirror.pnl.gov/releases/14.04.1/ubuntu-14.04.1-server-amd64.iso 2>&1 | tee -a output.log

    dialog --backtitle "image download COMPLETED!!"\
	 --title "Please Run Mount Local Files next!" --clear\
	 --msgbox "$(cat output.log)" 40 90

}
function MountLocalFiles() {
    dialog --backtitle "Unpacking ubuntu 14.04.1 server image"\
     --title "Unpacking......" --clear\
      --infobox "Unpacking Ubuntu Server, this could take a long time... :)" 40 90

	mkdir dockerfiles/pxebooter/isomount; mkdir dockerfiles/pxebooter/installfiles 2>&1 | tee -a output.log

	sudo mount -o loop `pwd`/ubuntu-14.04.1-server-amd64.iso dockerfiles/pxebooter/isomount 2>&1 | tee -a output.log

    sudo cp -fr dockerfiles/pxebooter/isomount/install/netboot/* dockerfiles/pxebooter/installfiles/

	dialog --backtitle "image setup COMPLETED!!"\
	 --title "Please Run Create PXE Booter next!" --clear\
	 --msgbox "$(cat output.log)" 40 90
}

function viewlogs() {
	dialog --textbox output.log 40 120
}


while true
do

dialog --clear --colors --help-button --backtitle "ubuntu server pxe boot docker container" \
--title "[ P X E B O O T - I N S T A L L E R - M E N U ]" \
--menu "The log is stored in /tmp/n \
use letter of the choice as a hot key, or the \
number keys 1-9 to choose an option.\n\n\
Choose from the options below" 25 80 30 \
downloadUbuntuServer "Run this first if you haven't downloaded the image" \
MountLocalFiles "Mount Local Files" \
createPXEbooter "Create PXE Booter" \
ViewLog "View the installer log" \
SaveLog "Save the installer log (exiting deletes logfile)" \
Exit "Exit to the shell" 2>"${INPUT}"

menuitem=$(<"${INPUT}")

case $menuitem in
	downloadUbuntuServer) downloadUbuntuServer;;
	MountLocalFiles) MountLocalFiles;;
	createPXEbooter) createPXEbooter;;
	ViewLog) viewlogs;;
	SaveLog) cp $OUTPUT ./SavedLog.log;;
	Exit) echo "Leaving the installer"; break;;
esac

done

# if temp files found, delete em
[ -f $OUTPUT ] && rm $OUTPUT
[ -f $INPUT ] && rm $INPUT