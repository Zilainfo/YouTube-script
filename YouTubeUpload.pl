use strict;
use warnings;
use Data::Dumper;
use LWP::UserAgent ();
use DBI;
use Source::PlaysTv;

my $Playstv = PlaysTv->new( 'LeagueofLegends');

get_paystv_video();

sub get_paystv_video {
  my ($attr) = @_;

  $Playstv->playstv_get_video_list();

  $Playstv->paystv_get_video();

  return 1;
}

# my $db = DBI->connect('DBI:mysql:playstv', 'root', '123');
# my $query = "SELECT * FROM mytable";

#    # my $mytable_output - $db->prepare($query);
#    # $mytable_output->execute;
#    # $mytable_output->finish;