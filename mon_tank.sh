#!/bin/bash

while :
do
	echo -n `date +%X`
	owread 28.BC42CC020000/temperature
	echo
	sleep 30
done
