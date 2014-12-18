#!/bin/bash

INPUT=/tmp/menu.sh.$$
>$INPUT
OUTPUT=output.log
>$OUTPUT
PXECID=/tmp/pxecontainer.id
>$PXECID

vi_editor=${EDITOR-vi}

trap "rm $OUTPUT; rm $INPUT; exit" SIGHUP SIGINT SIGTERM

function baseTools(){
	sudo apt-get install --force-yes --yes bridge-utils
}

function createPXEbooter(){
    dialog --backtitle "Starting docker build!"\
     --title "Installing......" --clear\
      --infobox "Setting up your pxe installer :)" 40 90

    sudo docker build -t pxeinstaller dockerfiles/pxebooter 2>&1 | tee -a $OUTPUT

    dialog --backtitle "PXE Booter Install COMPLETED!!"\
	 --title "Finished Install! Run PXE Booter Next" --clear\
	 --msgbox "$(cat output.log)" 40 90
}

function downloadUbuntuServer(){
    dialog --backtitle "downloading ubuntu 14.04.1 server image"\
     --title "Downloading......" --clear\
      --infobox "Downloading Ubuntu Server, this could take a long time... :)" 40 90

    wget http://mirror.pnl.gov/releases/14.04.1/ubuntu-14.04.1-server-amd64.iso 2>&1 | tee -a $OUTPUT

    dialog --backtitle "image download COMPLETED!!"\
	 --title "Please Run Mount Local Files next!" --clear\
	 --msgbox "$(cat output.log)" 40 90
}

function MountLocalFiles() {
    dialog --backtitle "Unpacking ubuntu 14.04.1 server image"\
     --title "Unpacking......" --clear\
      --infobox "Unpacking Ubuntu Server, this could take a long time... :)" 40 90

	mkdir dockerfiles/pxebooter/isomount; mkdir dockerfiles/pxebooter/installfiles 2>&1 | tee -a $OUTPUT

	sudo mount -o loop `pwd`/ubuntu-14.04.1-server-amd64.iso dockerfiles/pxebooter/isomount 2>&1 | tee -a $OUTPUT

    sudo cp -fr dockerfiles/pxebooter/isomount/install/netboot/* dockerfiles/pxebooter/installfiles/

	dialog --backtitle "image setup COMPLETED!!"\
	 --title "Please Run Create PXE Booter next!" --clear\
	 --msgbox "$(cat output.log)" 40 90
}

function unMountLocalFiles() {
    dialog --backtitle "removing mounts"\
     --title "unmounting......" --clear\
      --infobox "Unmounting filesystems" 40 90

	sudo umount dockerfiles/pxebooter/isomount 2>&1 | tee -a $OUTPUT

    dialog --backtitle "done unmounting"\
	 --title "UnMounting complete!" --clear\
	 --msgbox "$(cat output.log)" 40 90
}

function viewlogs() {
	dialog --textbox output.log 40 120
}

function setupNetworking() {

	brctlinst=$(dpkg-query -W --showformat='${Status}\n' bridge-utils|grep "install ok installed")
	if [ "" == "$brctlinst" ]; then
		echo "No brctl. Installing"
		baseTools
	fi

    dialog --title "What is the interface you want to use?"\
     --backtitle "Interface" --clear\
      --inputbox "Interface:" 8 60 2>$INPUT

    response=$?

	INTNAME=$(<$INPUT)

    sudo ./pipework br0 $PXECID 192.168.242.1/24 2>&1 | tee -a $OUTPUT

	sudo brctl addif br0 $INTNAME 2>&1 | tee -a $OUTPUT

	dialog --backtitle "done setting up networking"\
	 --title "Network Setup Complete!" --clear\
	 --msgbox "$(cat output.log)" 40 90
}

function runPXEbooter(){
	dialog --backtitle "Starting PXE booter docker instance"\
     --title "Booting PXE server......" --clear\
      --infobox "Starting server, this could take a some time... :)" 40 90

	sudo docker kill pxebooter 2>&1 | tee -a $OUTPUT
	sudo docker rm pxebooter 2>&1 | tee -a $OUTPUT
    PXECID=$(sudo docker run -d --name pxebooter --volume /tmp/data:/data -p 53:53 -p 26:26 --privileged pxeinstaller 2>&1 | tee -a $OUTPUT)

    dialog --backtitle "PXE Booter Started: $PXECID"\
	 --title "Please Run Setup Networking next!" --clear\
	 --msgbox "$(docker logs pxebooter)" 40 90
}

function destroyPXEbooter(){

	dialog --backtitle "Killing PXE booter docker instance"\
     --title "Killing PXE server......" --clear\
      --infobox "Killing server" 40 90

	sudo docker kill pxebooter 2>&1 | tee -a $OUTPUT
	sudo docker rm pxebooter 2>&1 | tee -a $OUTPUT

    dialog --backtitle "PXE Booter Killed"\
	 --title "Killed container" --clear\
	 --msgbox "$(cat output.log)" 40 90

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
unMountLocalFiles "UnMount Local Files" \
createPXEbooter "Create PXE Booter" \
runPXEbooter "Run PXE Booter" \
setupNetworking "Setup Networking" \
destroyPXEbooter "Destroy Instance" \
ViewLog "View the installer log" \
SaveLog "Save the installer log (exiting deletes logfile)" \
Exit "Exit to the shell" 2>"${INPUT}"

menuitem=$(<"${INPUT}")

case $menuitem in
	downloadUbuntuServer) downloadUbuntuServer;;
	MountLocalFiles) MountLocalFiles;;
	unMountLocalFiles) unMountLocalFiles;;
	createPXEbooter) createPXEbooter;;
	runPXEbooter) runPXEbooter;;
	setupNetworking) setupNetworking;;
	destroyPXEbooter) destroyPXEbooter;;
	ViewLog) viewlogs;;
	SaveLog) cp $OUTPUT ./SavedLog.log;;
	Exit) echo "Leaving the installer"; break;;
esac

done

# if temp files found, delete em
[ -f $OUTPUT ] && rm $OUTPUT
[ -f $INPUT ] && rm $INPUT