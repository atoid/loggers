#!/usr/bin/perl

use strict;
use POSIX;
use RRDs;
use OW;
use String::Util qw(trim);

chdir "/dev/shm";

OW::init("4304");

my $tank = trim(OW::get("28.BC42CC020000/temperature"));
my $gas  = trim(OW::get("10.793DAE020800/temperature"));
my $liq  = trim(OW::get("28.AE8CCC020000/temperature"));

OW::finish();

RRDs::update("vilp.rrd", "N:$tank:$gas:$liq");

RRDs::graph("/var/www/temps_4h.png",
			"-w 400",
			"-h 120",
			"--slope-mode",
			"--start=-14400",
			"--end=now",
			"--vertical-label=t (°C)",
			"--title=VILP last 4h",
			"DEF:tank=vilp.rrd:tank:MAX",
			"DEF:gas=vilp.rrd:gas:MAX",
			"DEF:liq=vilp.rrd:liq:MAX",
			"LINE1:tank#ff0000:Tank",
			"LINE1:gas#00ff00:Gas",
			"LINE1:liq#0000ff:Liq"
			);

RRDs::graph("/var/www/temps_24h.png",
			"-w 400",
			"-h 120",
			"--slope-mode",
			"--start=-86400",
			"--end=now",
			"--vertical-label=t (°C)",
			"--title=VILP last 24h",
			"DEF:tank=vilp.rrd:tank:MAX",
			"DEF:gas=vilp.rrd:gas:MAX",
			"DEF:liq=vilp.rrd:liq:MAX",
			"LINE1:tank#ff0000:Tank",
			"LINE1:gas#00ff00:Gas",
			"LINE1:liq#0000ff:Liq"
			);

