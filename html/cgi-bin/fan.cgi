#!/usr/bin/perl

use strict;
use CGI;

my $cgi = new CGI;
my $mode = $cgi->param('mode') || "normal";

system("/bin/echo -n $mode > /var/www/fanmode.txt");

print "Content-type:text/plain\r\n\r\n";
print "Fan mode set to $mode";

exit;
