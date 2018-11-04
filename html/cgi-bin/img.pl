#!/usr/bin/perl -w

use strict;
use CGI;
use POSIX;
use DBI;
use Time::Local;
use Time::Piece;
use Time::Seconds;

# Common constants for plots
my $tic_day = "   %H";
my $tic_mon = "  %d";
my $tic_wk  = "          %a %d";

my $plot_temps = 'using 1:9 title "Tekn" with lines,\
     "" using 1:11 title "Meno" with lines,\
     "" using 1:10 title "Palu" with lines,\
     "" using 1:4 title "J\344te" with lines,\
     "" using 1:6 title "Ulko" with lines,\
     "" using 1:3 title "Tulo" with lines,\
     "" using 1:7 title "Pois" with lines,\
     "" using 1:8 title "Katt" with lines';

#use POSIX qw(locale_h);
#setlocale(LC_ALL, "fi_FI.utf8");

my $res_file = "/dev/shm/res" . floor(rand(1000)) . ".txt";
my $sql_res = "";

sub mysql_get_select($$$);
sub mysql_select($$);

sub render_temps_day($);
sub render_rh_day($);
sub render_kwh_day($);

sub render_temps_month($);
sub render_rh_month($);
sub render_kwh_month($);

sub render_temps_week($);
sub render_rh_week($);
sub render_kwh_week($);

my $cgi = new CGI;
my $cgi_date = $cgi->param('date') || `date +%Y-%m-%d|tr -d "\n"`;
my $cgi_img = $cgi->param('image') || 'temps';
my $cgi_span = $cgi->param('span') || 'day';

my $debug = $cgi->param('debug') || '0';
my $img_w = $cgi->param('width') || "640";
my $img_h = $cgi->param('height') || "480";

if ($debug == '0')
{
    print "Content-type: image/png\n\n";
}
else
{
    print "Content-type: text/plain\n\n";
}

my $select = mysql_get_select($cgi_date, $cgi_img, $cgi_span);
mysql_select($select, $res_file);

#if ($debug == '1')
#{
#    exit;
#}

if ($cgi_span eq "day")
{
    if ($cgi_img eq "temps")
    {
        render_temps_day($cgi_date);
    }

    if ($cgi_img eq "rh")
    {
        render_rh_day($cgi_date);
    }

    if ($cgi_img eq "kwh")
    {
        render_kwh_day($cgi_date);
    }
}
elsif ($cgi_span eq "month")
{
    if ($cgi_img eq "temps")
    {
        render_temps_month($cgi_date);
    }

    if ($cgi_img eq "rh")
    {
        render_rh_month($cgi_date);
    }

    if ($cgi_img eq "kwh")
    {
        render_kwh_month($cgi_date);
    }
}
else
{
    if ($cgi_img eq "temps")
    {
        render_temps_week($cgi_date);
    }

    if ($cgi_img eq "rh")
    {
        render_rh_week($cgi_date);
    }

    if ($cgi_img eq "kwh")
    {
        render_kwh_week($cgi_date);
    }
}

unlink ($res_file);
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

sub mysql_select($$)
{
    my $select = $_[0];
    my $file = $_[1];
    my $res = -1;

    #print "Select: $select\n";

    eval {
        my $dbh = DBI->connect ("dbi:mysql:dbname=talo", "root", "root", { RaiseError => 1 },);
        my $sth = $dbh->prepare ($select);
        $sth->execute();

        open (FILE, ">$file");

        my @row;
        while (@row = $sth->fetchrow_array ())
        {
            print FILE "$row[0] $row[1]\n";
            #if ($debug == '1')
            #{
            #    print "$row[0] $row[1]\n";
            #}
        }

        close (FILE);

        $sth->finish ();
        $dbh->disconnect ();

        $res = 0;
    };

    return $res;
}

sub get_wk_start($)
{
    my $cgi_date = $_[0];
    my $date = Time::Piece->strptime($cgi_date, "%Y-%m-%d");

    while ($date->wday != 2)
    {
        $date -= ONE_DAY;
    }
    return $date;
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
plot "$res_file" $plot_temps
EOF1

close (G);
}

sub render_temps_month($) {
my $cgi_date = substr $_[0], 0, 7;
open(G, "|gnuplot") or die "gnuplot failed";
print G <<EOF2;
set autoscale
set xtics 86400
set ytics auto
set title "L\344mp\366tilamittaukset $cgi_date"
set xlabel "P\344iv\344"
set ylabel "L\344mp\366tila (C)"
set terminal png medium size $img_w,$img_h
set output
set key left top
set grid
set timefmt "%Y-%m-%d %H:%M:%S"
set xdata time
set format x "$tic_mon"
set xrange ["$cgi_date-01 00:00":"$cgi_date-31 24:00"]
plot "$res_file" $plot_temps
EOF2

close (G);
}

sub render_temps_week($) {
my $cgi_date = $_[0];
my $date = get_wk_start($cgi_date);
my $week = $date->week;
my $str_s = $date->strftime("%Y-%m-%d");
$date += ONE_WEEK - ONE_DAY;
my $str_e = $date->strftime("%Y-%m-%d");
open(G, "|gnuplot") or die "gnuplot failed";
print G <<EOF2;
set autoscale
set xtics 86400
set ytics auto
set title "L\344mp\366tilamittaukset viikolla $week"
set xlabel "P\344iv\344"
set ylabel "L\344mp\366tila (C)"
set terminal png medium size $img_w,$img_h
set output
set key left top
set grid
set timefmt "%Y-%m-%d %H:%M:%S"
set locale "fi_FI.UTF-8"
set xdata time
set format x "$tic_wk"
set xrange ["$str_s 00:00":"$str_e 24:00"]
plot "$res_file" $plot_temps
EOF2

close (G);
}

sub render_rh_day($) {
my $cgi_date = $_[0];
open(G, "|gnuplot") or die "gnuplot failed";
print G <<EOF3;
set autoscale
set xtics 3600
set ytics auto nomirror
set title "Alapohja $cgi_date"
set xlabel "Aika"
set ylabel "RH (%)"
set terminal png medium size $img_w,$img_h
set output
set y2label "L\344mp\366tila (C)"
set y2tics auto
set y2range [-10:25]
set yrange [40:*]
set key left top
set grid
set timefmt "%Y-%m-%d %H:%M:%S"
set xdata time
set format x "$tic_day"
set xrange ["$cgi_date 00:00":"$cgi_date 24:00"]
#
# RH calculation
#
rh(vs,vo) = ((((5/vs*vo)-0.822)/0.031))
#rh(vs,vo) = (vo/vs-0.16)/0.0062
trh(vs,vo,t) = (rh(vs>0?vs:5,vo) / (1.0305+0.000044*t-0.0000011*t*t))
#
# Initialize a running sum
#
init(x) = (back1 = back2 = back3 = back4 = back5 = sum = 0)
#
plot sum = init(0),\\
     "$res_file" using 1:(trh(\$13,\$12,\$5)) title "RH" with lines axis x1y1,\\
     "" using 1:(\$5) title "L\344mp\366tila" with lines axis x1y2
EOF3

close (G);
}

sub render_rh_month($) {
my $cgi_date = substr $_[0], 0, 7;
open(G, "|gnuplot") or die "gnuplot failed";
print G <<EOF4;
set autoscale
set xtics 86400
set ytics auto nomirror
set title "Alapohja $cgi_date"
set xlabel "P\344iv\344"
set ylabel "RH (%)"
set terminal png medium size $img_w,$img_h
set output
set y2label "L\344mp\366tila (C)"
set y2tics auto
set y2range [-10:25]
set yrange [40:*]
set key left top
set grid
set timefmt "%Y-%m-%d %H:%M:%S"
set xdata time
set format x "$tic_mon"
set xrange ["$cgi_date-01 00:00":"$cgi_date-31 24:00"]
#
# RH calculation
#
rh(vs,vo) = ((((5/vs*vo)-0.822)/0.031))
#rh(vs,vo) = (vo/vs-0.16)/0.0062
trh(vs,vo,t) = (rh(vs>0?vs:5,vo) / (1.0305+0.000044*t-0.0000011*t*t))
#
# Initialize a running sum
#
init(x) = (back1 = back2 = back3 = back4 = back5 = sum = 0)
#
plot sum = init(0),\\
     "$res_file" using 1:(trh(\$13,\$12,\$5)) title "RH" with lines axis x1y1,\\
     "" using 1:(\$5) title "L\344mp\366tila" with lines axis x1y2
EOF4

close (G);
}

sub render_rh_week($) {
my $cgi_date = $_[0];
my $date = get_wk_start($cgi_date);
my $week = $date->week;
my $str_s = $date->strftime("%Y-%m-%d");
$date += ONE_WEEK - ONE_DAY;
my $str_e = $date->strftime("%Y-%m-%d");
open(G, "|gnuplot") or die "gnuplot failed";
print G <<EOF4;
set autoscale
set xtics 86400
set ytics auto nomirror
set title "Alapohja viikolla $week"
set xlabel "P\344iv\344"
set ylabel "RH (%)"
set terminal png medium size $img_w,$img_h
set output
set y2label "L\344mp\366tila (C)"
set y2tics auto
set y2range [-10:25]
set yrange [40:*]
set key left top
set grid
set timefmt "%Y-%m-%d %H:%M:%S"
set xdata time
set locale "fi_FI.UTF-8"
set format x "$tic_wk"
set xrange ["$str_s 00:00":"$str_e 24:00"]
#
# RH calculation
#
rh(vs,vo) = ((((5/vs*vo)-0.822)/0.031))
#rh(vs,vo) = (vo/vs-0.16)/0.0062
trh(vs,vo,t) = (rh(vs>0?vs:5,vo) / (1.0305+0.000044*t-0.0000011*t*t))
#
# Initialize a running sum
#
init(x) = (back1 = back2 = back3 = back4 = back5 = sum = 0)
#
plot sum = init(0),\\
     "$res_file" using 1:(trh(\$13,\$12,\$5)) title "RH" with lines axis x1y1,\\
     "" using 1:(\$5) title "L\344mp\366tila" with lines axis x1y2
EOF4

close (G);
}

sub prepare_kwh($$) {
    my $cgi_date = $_[0];
    my $mode = $_[1];
    open (FILE, "$res_file") or die "open file failed";
    my @lines = <FILE>;
    close (FILE);
    my $line;
    my @tmp;

    my @hrs_start = (0) x $mode;
    my @hrs_end = (0) x $mode;

    @tmp = split(/ /, $lines[0]);
    my $base = Time::Piece->strptime($tmp[0], "%Y-%m-%d");

    my $i;
    foreach $line (@lines)
    {
        @tmp = split(/ /, $line);
  
        if ($mode == 24)
        {
            $i = substr ($tmp[1], 0, 2);
        }
        elsif ($mode == 31)
        {
            $i = substr ($tmp[0], 8, 2) - 1;
        }
        else
        {
            my $next = Time::Piece->strptime($tmp[0], "%Y-%m-%d");
            $i = ($next - $base)->days;
        }

        if ($hrs_start[$i] == 0)
        {
            $hrs_start[$i] = $tmp[2];
        }

        $hrs_end[$i] = $tmp[2];
    }

    my $hrs = "";
    my $sum = 0;
    my $delta = 0;

    for ( $i = 0; $i < $mode; $i++ )
    {
        if ($i < ($mode-1) && $hrs_start[$i] > 0 && $hrs_start[$i+1] > 0)
        {
            $hrs_end[$i] = $hrs_start[$i+1];
        }

        $delta = ($hrs_end[$i] - $hrs_start[$i]);
        if ($delta > 0)
        {
            if ($mode == 24)
            {
                $hrs .= "$cgi_date $i:30 $delta\n";
            }
            elsif ($mode == 31)
            {
                my $day = $i + 1;
                $hrs .= substr ($cgi_date, 0, 7) . "-$day 12:00 $delta\n";
            }
            else
            {
                $hrs .= $base->strftime("%Y-%m-%d") . " 12:00 $delta\n";
            }
            $sum += $delta;
        }

        $base += ONE_DAY;
    }

    if ($hrs eq "")
    {
        $hrs = substr ($cgi_date, 0, 10) . " 12:00 0\n";
    }

    $sum = sprintf("%.2f", $sum/10000);

    return ($hrs, $sum);
}

sub render_kwh_day($) {
my $cgi_date = $_[0];
my ($hrs, $sum) = prepare_kwh($cgi_date, 24);
open(G, "|gnuplot") or die "gnuplot failed";
print G <<EOF5;
set autoscale
set xtics 3600
set ytics auto
set title "Kulutus $cgi_date $sum kWh"
set xlabel "Aika"
set ylabel "kWh"
set terminal png medium size $img_w,$img_h
set output
set yrange [0:*]
set style fill solid 0.5
set grid
set timefmt "%Y-%m-%d %H:%M:%S"
set xdata time
set format x "$tic_day"
set xrange ["$cgi_date 00:00":"$cgi_date 24:00"]
plot "-" using 1:(\$3/10000) title "kWh" with boxes,\\
     "" using 1:(\$3/10000+0.25):(sprintf("%.1f",(\$3/10000))) notitle with labels font "small"
$hrs
e
$hrs
e
exit
EOF5

close (G);
}

sub render_kwh_week($)
{
my $cgi_date = $_[0];
my ($hrs, $sum) = prepare_kwh($cgi_date, 7);
#print "\n$hrs\n$sum\n";
#return
my $date = get_wk_start($cgi_date);
my $week = $date->week;
my $str_s = $date->strftime("%Y-%m-%d");
$date += ONE_WEEK - ONE_DAY;
my $str_e = $date->strftime("%Y-%m-%d");

open(G, "|gnuplot") or die "gnuplot failed";
print G <<EOF7;
set autoscale
set xtics 86400
set ytics auto
set title "Kulutus viikolla $week $sum kWh"
set xlabel "P\344iv\344"
set ylabel "kWh"
set terminal png medium size $img_w,$img_h
set output
set yrange [0:*]
set style fill solid 0.5
set grid
set timefmt "%Y-%m-%d %H:%M:%S"
set locale "fi_FI.UTF-8"
set xdata time
set format x "$tic_wk"
set xrange ["$str_s 00:00":"$str_e 24:00"]
plot "-" using 1:(\$3/10000) title "kWh" with boxes,\\
     "" using 1:(\$3/10000+2):(sprintf("%.1f",(\$3/10000))) notitle with labels font "small"
$hrs
e
$hrs
e
EOF7

close (G);
}

sub render_kwh_month($) {
my $cgi_date = substr $_[0], 0, 7;
my ($hrs, $sum) = prepare_kwh($cgi_date, 31);
#print $hrs;
#return;
open(G, "|gnuplot") or die "gnuplot failed";
print G <<EOF6;
set autoscale
set xtics 86400
set ytics auto
set title "Kulutus $cgi_date $sum kWh"
set xlabel "P\344iv\344"
set ylabel "kWh"
set terminal png medium size $img_w,$img_h
set output
set yrange [0:*]
set style fill solid 0.5
set grid
set timefmt "%Y-%m-%d %H:%M:%S"
set xdata time
set format x "$tic_mon"
set xrange ["$cgi_date-01 00:00":"$cgi_date-31 24:00"]
plot "-" using 1:(\$3/10000) title "kWh" with boxes,\\
     "" using 1:(\$3/10000+2):(sprintf("%.1f",(\$3/10000))) notitle with labels font "small"
$hrs
e
$hrs
e
EOF6

close (G);
}
