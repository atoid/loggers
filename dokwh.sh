#!/bin/bash

# Get current counter value
kwh_current=`owread 1D.5F810E000000/counters.A|tr -d " "`

if [ -z $kwh_current ]
then
  echo "`date` failed kwh counter" >> /run/shm/1werr.log
else
  # Insert to database
  /usr/bin/mysql -uroot -proot -e "INSERT INTO talo.energia(laskuri) VALUES (\"$kwh_current\")"
fi

