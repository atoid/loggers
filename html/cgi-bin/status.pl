#!/usr/bin/perl

use strict;
use CGI;
use JSON;

my $cgi = new CGI;
my $hash = { status => `sshpass -p raspberry ssh pi\@192.168.0.134 /home/pi/git/vilp/status.sh` };
my $str = to_json($hash);

print $cgi->header(-type=>"application/json", -Access_Control_Allow_Origin=>"*").$str;

exit;
