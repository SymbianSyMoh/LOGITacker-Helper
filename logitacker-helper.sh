#!/bin/bash

function logitackerCheck(){
echo "[*] Checking if LOGITacker is running..."
if screen -list | grep -q "LOGITacker"; then
echo "[*] LOGITacker screen is already running!"
echo "[*] LOGITacker dongles connected:"
logitacker=$(screen -ls | grep LOGITacker | awk '{print $1}')
echo " > "$logitacker
scrName=$logitacker
else
#Assuming that LOGITacker dongle is running on serial port /dev/ttyACM0 as an initial port
echo "[*] LOGITacker screen is not running or device is not inserted, Trying to run..."
screen -S LOGITacker -L -d -m /dev/ttyACM0
sleep 2
logitackerCheck
fi
}

function eraseFlash(){
echo "Press ENTER to start erasing flash procedures..."&&read
echo "[*] Getting version..."
screen -S $scrName -p 0 -X stuff "version^M"
echo "[*] Erasing flash, please wait..."
screen -S $scrName -p 0 -X stuff "erase_flash^M"
sleep 7
echo "[*] Please unplug the dongle and replug it again then press ENTER..."&&read
logitackerCheck
}

function flashDevices(){
#Please alter both DONGLE_MAC_HERE and DONGLE_LINK_KEY_HERE of your own dongle(s) and repeat the lines if you have multiple dongles
echo "[*] Flashing devices, please wait..."
screen -S $scrName -p 0 -X stuff "^M"
screen -S $scrName -p 0 -X stuff "devices add DONGLE_MAC_HERE DONGLE_LINK_KEY_HERE^M"
screen -S $scrName -p 0 -X stuff "devices storage save DONGLE_MAC_HERE^M"
}

function flashSettings(){
#Example settings store, please change awareness with your own script you want to load it on LOGITacker's boot.
echo "[*] Flashing settings, please wait..."
screen -S $scrName -p 0 -X stuff "^M"
screen -S $scrName -p 0 -X stuff "options inject default-script awareness^M"
screen -S $scrName -p 0 -X stuff "options global bootmode discover^M"
screen -S $scrName -p 0 -X stuff "options global workmode unifying^M"
screen -S $scrName -p 0 -X stuff "options discover auto-store-plain-injectable off^M"
screen -S $scrName -p 0 -X stuff "options discover onhit continue^M"
screen -S $scrName -p 0 -X stuff "options inject auto-inject-count 1^M"
screen -S $scrName -p 0 -X stuff "options inject onsuccess continue^M"
screen -S $scrName -p 0 -X stuff "options inject onfail continue^M"
screen -S $scrName -p 0 -X stuff "options store^M"
screen -S $scrName -p 0 -X stuff "options show^M"
}

function flashPayloads(){
echo "[*] Flashing payloads, please wait..."
screen -S $scrName -p 0 -X stuff "script clear^M"
screen -S $scrName -p 0 -X stuff "script delay 3000^M"
screen -S $scrName -p 0 -X stuff "script string Your computer could be hacked. Contact us for more information!^M"
screen -S $scrName -p 0 -X stuff "script press ENTER^M"
screen -S $scrName -p 0 -X stuff "script store awareness^M"
screen -S $scrName -p 0 -X stuff "script clear^M"
}

function flashSummary(){
echo "Press ENTER to show the flash summary..."&&read
echo "[*] Showing flash process summary..."
screen -S $scrName -p 0 -X stuff "^M"
screen -S $scrName -p 0 -X stuff "clear^M"
sleep 1
echo "[*] Showing version..."
screen -S $scrName -p 0 -X stuff "version^M"
sleep 1
echo "[*] Listing scripts..."
screen -S $scrName -p 0 -X stuff "script list^M"
sleep 1
echo "[*] Listing devices..."
screen -S $scrName -p 0 -X stuff "devices storage list^M"
sleep 1
echo "[*] Showing options..."
screen -S $scrName -p 0 -X stuff "options show^M"
echo "[*] Done!"
}

function helpTacker(){
echo "Modes: eraseflash, flashfull, flashdevices, flashsettings, flashpayloads, flashsummary"
exit
}

if [[ -z $1 ]] || [[ $1 = "help" ]] ; then
helpTacker

elif [[ $1 = "eraseflash" ]]; then
logitackerCheck
eraseFlash

elif [[ $1 = "flashfull" ]]; then
logitackerCheck
eraseFlash
logitackerCheck
flashDevices
flashsettings
flashPayloads
flashSummary

elif [[ $1 = "flashdevices" ]]; then
logitackerCheck
flashDevices
screen -S $scrName -p 0 -X stuff "devices storage list^M"

elif [[ $1 = "flashsettings" ]]; then
logitackerCheck
flashNormalSettings
screen -S $scrName -p 0 -X stuff "options show^M"

elif [[ $1 = "flashpayloads" ]]; then
logitackerCheck
flashPayloads

elif [[ $1 = "flashsummary" ]]; then
logitackerCheck
flashSummarySteps

else
helpTacker

fi
