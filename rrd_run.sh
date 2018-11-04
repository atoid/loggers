#!/bin/bash

while :
do
	echo "Updating..."
	./rrd_update.pl
	sleep 60
done
