#!/bin/bash

clear
echo "*** Matty's Checkm8 APNonce Setter ***"
echo "Do you want to input a generator? (y,n)"

read input

if [ $input = y ];
then
    echo "Please enter your desired generator."

    read generator

    echo "Your generator is $generator"
elif [ $input = n ];
then

    echo "Please drag and drop the SHSH file that you want to downgrade with into this terminal window then press enter"

    read shsh

    echo "Is $shsh the correct location and file name of your SHSH? (y/n)"

    read pass

        if [ $pass == yes ] || [ $pass == Yes ] || [ $pass == y ] || [ $pass == Y ];
        then
            echo "Continuing with given SHSH"

        elif [ $pass == no ] || [ $pass == No ] || [ $pass == n ] || [ $pass == n ];
        then
            echo "Please restart script and give the correct location and file name"
            echo "Exiting..."
            exit

        else
            echo "Unrecognised input"
            echo "Exiting..."
            exit

        fi

        if [ ${shsh: -6} == ".shsh2" ] || [ ${shsh: -5} == ".shsh" ];
        then
            echo "File verified as SHSH2 file, continuing"

        else
            echo "Please ensure that the file extension is either .shsh or .shsh2 and retry"
            echo "Exiting..."
            exit
        fi

        echo "Getting generator from SHSH"

        getGenerator() {
        echo $1 | grep "<string>0x" $shsh  | cut -c10-27
        }
        generator=$(getGenerator $shsh)

        if [ -z "$generator" ]
        then
            echo "[ERROR] SHSH does not contain a generator!"
            echo "[ERROR] Please use a different SHSH with a generator!"
            echo "[ERROR] SHSH saved with shsh.host (will show generator) or tsssaver.1conan.com (in noapnonce folder) are acceptable"
            echo "Exiting..."
            exit
        else
            echo "Your generator is: $generator"
        fi

else
    echo "Input not recognized, Exiting..."
    exit
fi

echo "$generator"
echo "getting device model"
echo "SE found"

echo "Please connect device in DFU mode. Press enter when ready to continue"

read randomIrrelevant

echo "Starting eclipsa"

cd files
echo "Device has a samsung chip, using eclipsa8000"
./eclipsa8000
sleep 1
echo "Device is now in pwned DFU mode with signature checks removed (Thanks to 0x7ff)"

sleep 2

echo "Uploading bootchain"

iBSS="iBSS.$device.img4"
iBEC="iBEC.$device.img4"
echo "Uploading $iBSS"
./irecovery -f $iBSS
sleep 2
echo "Uploading $iBEC"
./irecovery -f $iBEC
sleep 2

echo "We should be in pwned recovery mode now"


echo "Current nonce"
./irecovery -q | grep NONC
echo "Setting nonce to $generator"
./irecovery -c "bgcolor 255 0 0"
sleep 1
./irecovery -c "setenv com.apple.System.boot-nonce $generator"
sleep 1
./irecovery -c "saveenv"
sleep 1
./irecovery -c "setenv auto-boot false"
sleep 1
./irecovery -c "saveenv"
sleep 1
./irecovery -c "reset"
echo "Waiting for device to restart into recovery mode"
sleep 7
echo "New nonce"
./irecovery -q | grep NONC

echo "We are done!"
echo ""
echo "You can now futurerestore to the firmware that this SHSH is vaild for"
echo "Assuming that signed SEP and Baseband are compatible"
