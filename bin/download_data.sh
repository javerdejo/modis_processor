#!/bin/bash
# ECOSUR-ERIS Project
# Author: Javier Arellano-Verdejo
# Date: april 2018

JEP=/eris/l2processor
URL="https://oceandata.sci.gsfc.nasa.gov/cgi/getfile"
LOGFILE=status.log
DATADIR=$JEP/data/bz2

echo "Downloading files ..."

op=$1
case $op in
  -d|--data)
  DATAFILE=$2
  ;;
  -h|--help)
  echo "usage: $0 [-d|--data]"
  echo "  -d or --data for data"
  exit 1
  ;;
  *)
  echo "invalid option"
  exit 1
esac

data=`cat $DATAFILE`
for FILENAME in $data
do
  if [ -e $DATADIR/$FILENAME ]
  then
    echo "$FILENAME file is currently updated"
  else
    echo -ne "Downloading:" $FILENAME " ... "
    wget -q $URL/$FILENAME
    if [ $? -eq 0 ]
    then
      echo "[ ok ]"
      mv $FILENAME $DATADIR
      touch $DATADIR/$FILENAME.jep
    else
      echo "[ error ]"
      echo $FILENAME >> $LOGFILE
    fi
  fi
done
