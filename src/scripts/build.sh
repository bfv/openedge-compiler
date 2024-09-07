#!/bin/bash

scriptpath=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")

echo running $scriptpath/build.sh


ANT_HOME=/usr/dlc/ant; export ANT_HOME
DLC=/usr/dlc; export DLC
PATH=$PATH:$DLC:$DLC/bin; export PATH

# because I can't set secret right now.
${ANT_HOME}/bin/ant -f ${scriptpath}/../build.xml -Ddeploydir=/artifacts -Dtmpdir=/usr/wrk -lib $DLC/pct 

$DLC/bin/prolib /artifacts/sports2020.pl -list > /artifacts/sports2020.rcode.list
