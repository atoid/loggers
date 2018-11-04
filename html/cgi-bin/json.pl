#!/usr/bin/perl

use CGI;
use Time::Piece;
use Time::Seconds;
use JSON;
use POSIX;

#my $date = Time::Piece->strptime("2012-40-1", "%Y-%W-%w");
#my $date = Time::Piece->strptime("2012-11-20", "%Y-%m-%d");

#print "$date\n";
#$date += ONE_DAY;
#print "$date\n";

#print $date->wday . "\n";

#my $data_str = '{ "version":1, "date":"2013-01-09 20:49:44", "lat": 55.3321, "long":64.1123, "ph":7.1, "fe":4.2 }';
#my $res = -1;

#eval {
#    $data = from_json($data_str);
#
#    if ($data->{version} == 1)
#    {
#        while ( my ($key, $value) = each(%$data) )
#        {
#            print "$key => $value\n";
#        }
#        $res = 0;
#    }
#};

#print "\nstatus: $res\n";

$cgi = new CGI;

my @meas;

my $date = Time::Piece->strptime("2014-01-16", "%Y-%m-%d");

for ($i = 0; $i < 20; $i++)
{
    my $rx = floor(rand(400) - 200) / 1000;
    my $ry = floor(rand(800) - 400) / 1000;
    my $ph = 4 + rand(4);
    my $fe = 3 + rand(4);

    my $hash = {
        version => 1,
        date => $date->strftime("%Y-%m-%d %H:%M:%S"),
        lat => 64.217131 + $rx,
        lng => 27.723999 + $ry,
        ph => $ph,
        fe => $fe
    };

    push @meas, $hash;

    $date += ONE_DAY;
}

my $str = to_json(\@meas);

print $cgi->header(-type=>"application/json", -Access_Control_Allow_Origin=>"*").$str;

exit;

