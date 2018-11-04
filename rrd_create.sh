#!/bin/bash

rrdtool create /dev/shm/vilp.rrd --step 120 DS:tank:GAUGE:240:0:100 DS:gas:GAUGE:240:0:100 DS:liq:GAUGE:240:0:100 RRA:MAX:0.5:1:1440
