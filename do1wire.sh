#!/bin/bash

NUM_SENSORS=`cat sensors.txt|wc -l`
SENSORS=0
TRY=10
FILES=`cat sensors.txt | tr -s "\n" " "`

while [ $TRY -gt 0 ]
do
  RESULTS=`owread $FILES`
  RESULTS=`echo $RESULTS | tr -s " "`
  SENSORS=`echo $RESULTS | wc -w`

  if [ $SENSORS -ge $NUM_SENSORS ]
  then
    break
  fi

  if [ $TRY -eq 9 ]
  then
    echo -n "`date` ($SENSORS) $RESULTS " >> /run/shm/1werr.log
  fi

  TRY=`expr $TRY - 1`
  sleep 2
done

if [ $TRY -lt 9 ]
then
  echo "($TRY)" >> /run/shm/1werr.log
fi

if [ $SENSORS -ge $NUM_SENSORS ]
then
  # Insert to database
  /usr/bin/mysql -uroot -proot -e "INSERT INTO talo.lampotilat(sensorit) VALUES (\"$RESULTS\")"
else
  echo "`date` failed after retries ($SENSORS)" >> /run/shm/1werr.log
fi

# Energy counter
/home/pi/dokwh.sh

# Cache base images
wget -q "http://localhost/cgi-bin/img.pl?image=temps&span=day" -O /var/www/temps.png
wget -q "http://localhost/cgi-bin/img.pl?image=kwh&span=day" -O /var/www/kwh.png
wget -q "http://localhost/cgi-bin/img.pl?image=rh&span=day" -O /var/www/rh.png

# Put online
/home/pi/putftp.sh /var/www temps.png
/home/pi/putftp.sh /var/www kwh.png
/home/pi/putftp.sh /var/www rh.png
