#!/bin/sh

PLD=$1
JED=$2

DATE=$( util/date.sh $PLD )
perl -pi -e "s/^Created.*/Created         $DATE/" $JED

CHECKSUM=$( LANG= util/jedcrc $JED| sed "s/Checksum: //" |tr -d "\r")
perl -pi -e "s/\\003..../\\003$CHECKSUM/" $JED

echo "Fixed up $JED ($DATE, CHK=$CHECKSUM)"
