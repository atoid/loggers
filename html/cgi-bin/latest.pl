#!/usr/bin/perl -w

use strict;
use CGI;
use POSIX;
use DBI;

sub get_last($);

my $cgi = new CGI;
my $cgi_type = $cgi->param('type') || "kwh";

print "Content-type: text/plain\n\n";
print get_last($cgi_type);

exit;

#
#
#

sub get_last($)
{
    my $type = $_[0];
    my $res = "Ei lisätietoja";

    eval {
        my $dbh = DBI->connect ("dbi:mysql:dbname=talo", "root", "root", { RaiseError => 1 },);
        my $sth;
        my @row;

        if ($type eq "kwh")
        {
            $sth = $dbh->prepare ("SELECT * FROM energia WHERE DATE(aika)=CURDATE() ORDER BY aika DESC LIMIT 2");
            $sth->execute();

            my @pwr = (0) x 2;
            my $i = 0;

            while (@row = $sth->fetchrow_array ())
            {
                $pwr[$i] = $row[1];
                $i++;
            }

            if ($i > 1)
            {
                $res = "Teho(W): ".sprintf("%.0f", ($pwr[0] - $pwr[1]) * 1.2);
            }
            else
            {
                $res = "Teho(W): -";
            }

            $sth = $dbh->prepare ("SELECT * FROM energia WHERE DATE(aika)=CURDATE() ORDER BY aika ASC LIMIT 1");
            $sth->execute();

            while (@row = $sth->fetchrow_array ())
            {
                my $kwh;
                $kwh = sprintf("%.0f", ($pwr[0] - $row[1]) / 10000);
                $res .= "\nkWh(vrk): $kwh";
            }

            #$sth = $dbh->prepare ("SELECT * FROM energia WHERE YEARWEEK(aika, 3)=YEARWEEK(CURDATE(), 3) ORDER BY aika ASC LIMIT 1");
            #$sth->execute();

            #while (@row = $sth->fetchrow_array ())
            #{
            #    my $kwh;
            #    $kwh = sprintf("%.0f", ($pwr[0] - $row[1]) / 10000);
            #    $res .= "\nkWh(vko): $kwh";
            #}

            #$sth = $dbh->prepare ("SELECT * FROM energia WHERE MONTH(aika)=MONTH(CURDATE()) AND YEAR(aika)=YEAR(CURDATE()) ORDER BY aika ASC LIMIT 1");
            #$sth->execute();

            #while (@row = $sth->fetchrow_array ())
            #{
            #    my $kwh;
            #    $kwh = sprintf("%.0f", ($pwr[0] - $row[1]) / 10000);
            #    $res .= "\nkWh(kk): $kwh";
            #}

            #$sth = $dbh->prepare ("SELECT * FROM energia WHERE YEAR(aika)=YEAR(CURDATE()) ORDER BY aika ASC LIMIT 1");
            #$sth->execute();

            #while (@row = $sth->fetchrow_array ())
            #{
            #    my $kwh;
            #    $kwh = sprintf("%.0f", ($pwr[0] - $row[1]) / 10000);
            #    $res .= "\nkWh(a): $kwh";
            #}
        }
        else
        {
            $sth = $dbh->prepare ("SELECT * FROM lampotilat WHERE DATE(aika)=CURDATE() ORDER BY aika DESC LIMIT 1");
            $sth->execute();

            @row = $sth->fetchrow_array ();

            my @val = split (/ /, $row[1]);

            if ($type eq "temps")
            {
                $res  = sprintf("Ulkoilma: %.1f\n".
                                "Poistoilma: %.1f\n".
                                "Tuloilma: %.1f\n".
                                "Jäteilma: %.1f\n".
                                "Kattila: %.1f\n".
                                "Menovesi: %.1f\n".
                                "Paluuvesi: %.1f\n".
                                "Tekninen tila: %.1f",
                                $val[3], $val[4], $val[0], $val[1], $val[5], $val[8], $val[7], $val[6]);
            }
            else
            {
                my $vs = $val[10];
                my $vo = $val[9];
                my $t = $val[2];

                my $rh = (((5/$vs*$vo)-0.822)/0.031);
                my $trh = $rh / (1.0305+0.000044*$t-0.0000011*$t*$t);

                $res = sprintf("Alapohja: %.1f\nKosteus(%): %.1f", $t, $trh);
            }
        }

        $sth->finish ();
        $dbh->disconnect ();
    };

    return $res;
}
