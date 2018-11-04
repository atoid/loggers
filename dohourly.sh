#!/bin/bash

# Get monthly images
wget -q "http://localhost/cgi-bin/img.pl?image=temps&span=month" -O /var/www/temps_m.png
wget -q "http://localhost/cgi-bin/img.pl?image=kwh&span=month" -O /var/www/kwh_m.png
wget -q "http://localhost/cgi-bin/img.pl?image=rh&span=month" -O /var/www/rh_m.png

# Put online
/home/pi/putftp.sh /var/www temps_m.png
/home/pi/putftp.sh /var/www kwh_m.png
/home/pi/putftp.sh /var/www rh_m.png
