#!/usr/bin/perl

use strict;

my $ups = `/sbin/apcaccess|grep 'STATUS\\|BCHARGE\\|TIMELEFT'`;

print "Content-type:text/plain\r\n\r\n";
print "$ups";

exit;
