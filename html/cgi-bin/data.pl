#!/usr/bin/perl -w

use strict;
use CGI;
use POSIX;
use DBI;
use Time::Local;
use Time::Piece;
use Time::Seconds;

sub mysql_get_select($$$);
sub mysql_select($);

my $cgi = new CGI;
my $cgi_date = $cgi->param('date') || `date +%Y-%m-%d|tr -d "\n"`;
my $cgi_img = $cgi->param('image') || 'temps';
my $cgi_span = $cgi->param('span') || 'day';

my $debug = $cgi->param('debug') || '0';

print "Content-type: text/plain\n\n";

my $select = mysql_get_select($cgi_date, $cgi_img, $cgi_span);
mysql_select($select);

exit;

#
#
#

sub mysql_get_select($$$)
{
    my $cgi_date = $_[0];
    my $cgi_img = $_[1];
    my $cgi_span = $_[2];

    my $select = "SELECT * FROM ";

    if ($cgi_img eq "kwh")
    {
        $select .= "energia ";
    }
    else
    {
        $select .= "lampotilat ";
    }

    if ($cgi_span eq "month")
    {
        $select .= "WHERE YEAR(aika)=YEAR(\"$cgi_date\") AND MONTH(aika)=MONTH(\"$cgi_date\") ";
    }
    elsif ($cgi_span eq "day")
    {
        $select .= "WHERE DATE(aika)=DATE(\"$cgi_date\") ";
    }
    else
    {
        $select .= "WHERE YEARWEEK(aika, 3)=YEARWEEK(\"$cgi_date\", 3) ";
    }

    $select .= "ORDER BY aika ASC";

    return $select
}

sub mysql_select($)
{
    my $select = $_[0];
    my $res = -1;

    eval {
        my $dbh = DBI->connect ("dbi:mysql:dbname=talo", "root", "root", { RaiseError => 1 },);
        my $sth = $dbh->prepare ($select);
        $sth->execute();

        my @row;
        while (@row = $sth->fetchrow_array ())
        {
            print "$row[0] $row[1]\n";
        }

        $sth->finish ();
        $dbh->disconnect ();

        $res = 0;
    };

    return $res;
}

