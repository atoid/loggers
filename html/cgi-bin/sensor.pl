#!/usr/bin/perl

use strict;
use CGI;
use JSON;

my $cgi = new CGI;
my @arr;

for (my $i = 0; ; $i++)
{
	my $sensor = $cgi->param("id$i") || last;
	my $t = `owread $sensor/temperature`;
	push @arr, $t;
}

my $kwh = $cgi->param("kwh") || 0;

if ($kwh)
{
	$kwh = `owread 1D.5F810E000000/counters.A`;
	push @arr, $kwh;
}

my $str = to_json(\@arr);
print $cgi->header(-type=>"application/json", -Access_Control_Allow_Origin=>"*").$str;

exit;
