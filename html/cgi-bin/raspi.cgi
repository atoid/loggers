#!/usr/bin/perl

use strict;
#use CGI;


my $t = `/opt/vc/bin/vcgencmd measure_temp`;
# returns temp=48.7'C

print "Content-type:text/plain\r\n\r\n";
print "$t\n";

exit;
