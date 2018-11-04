#!/usr/bin/perl -w

use strict;
use CGI;
use DBI;
use POSIX;
use Time::Local;
use Time::Piece;
use Time::Seconds;

# Common constants for plots
my $tic_day = "   %H";

my $plot_temps = 'using 1:3 title "Huone" with lines';

my $res_file = "/dev/shm/res" . floor(rand(1000)) . ".txt";
my $sql_res = "";

sub mysql_get_select($);
sub mysql_select($$);
sub render_temps_day($);

my $cgi = new CGI;
my $cgi_date = $cgi->param('date') || `date +%Y-%m-%d|tr -d "\n"`;

my $img_w = $cgi->param('width') || "640";
my $img_h = $cgi->param('height') || "480";

print "Content-type: image/png\n\n";

my $select = mysql_get_select($cgi_date);
mysql_select($select, $res_file);
render_temps_day($cgi_date);

unlink ($res_file);
exit;

#
#
#

sub mysql_get_select($)
{
    my $cgi_date = $_[0];

    my $select = "SELECT * FROM ";

    $select .= "lampotilat ";
    $select .= "WHERE DATE(aika)=DATE(\"$cgi_date\") ";
    $select .= "ORDER BY aika ASC";

    return $select
}

sub mysql_select($$)
{
    my $select = $_[0];
    my $file = $_[1];
    my $res = -1;

    eval {
        my $dbh = DBI->connect ("dbi:mysql:dbname=talo", "root", "root", { RaiseError => 1 },);
        my $sth = $dbh->prepare ($select);
        $sth->execute();

        open (FILE, ">$file");

        my @row;
        while (@row = $sth->fetchrow_array ())
        {
            print FILE "$row[0] $row[1]\n";
        }

        close (FILE);

        $sth->finish ();
        $dbh->disconnect ();

        $res = 0;
    };

    return $res;
}

sub render_temps_day($) {
my $cgi_date = $_[0];
open(G, "|gnuplot") or die "gnuplot failed";
print G <<EOF1;
set autoscale
set xtics 3600
set ytics auto
set title "L\344mp\366tilamittaukset $cgi_date"
set xlabel "Aika"
set ylabel "L\344mp\366tila (C)"
set terminal png medium size $img_w,$img_h
set output
set key left top
set grid
set timefmt "%Y-%m-%d %H:%M:%S"
set xdata time
set format x "$tic_day"
set xrange ["$cgi_date 00:00":"$cgi_date 24:00"]
set yrange [0:30]
plot "$res_file" $plot_temps
EOF1

close (G);
}

