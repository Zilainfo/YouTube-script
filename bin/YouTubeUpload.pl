use lib '../lib';
use strict;
use warnings;
use Data::Dumper;
use LWP::UserAgent ();
use POSIX;
use Net::PlaysTv;

my $directory =  '/usr/Video/';
my $Playstv = Net::PlaysTv->new('LeagueofLegends', $directory);

get_paystv_video();

sub get_paystv_video {
    my ($attr) = @_;

    $Playstv->playstv_get_video_list();

    my ($date) = strftime("%Y-%m-%d_%H:%M", localtime(time));

    $Playstv->paystv_get_video();

    system("cd $directory && for f in ./*.ts; do echo ". '"file \'$f\'"'. " >> $date.txt; done");

    $Playstv->{DBI}->disconnect;

    return 1;
}

# my $db = DBI->connect('DBI:mysql:playstv', 'root', '123');
# my $query = "SELECT * FROM mytable";

#    # my $mytable_output - $db->prepare($query);
#    # $mytable_output->execute;
#    # $mytable_output->finish;