#!/bin/bash

initialize() {

    rm lib/files/tmp/reports/*
    rm lib/files/tmp/verificationStatus/*
    rm lib/files/tmp/verifyFiles/*
    rm lib/files/tmp/progress/*
    > lib/files/tmp/attachedDisks.txt
    > lib/files/tmp/chosenDisks.txt
    > lib/files/tmp/chosenDisksDesc.txt
    > lib/files/tmp/usbDrives.txt

}
