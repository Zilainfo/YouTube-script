use lib '../lib';

use strict;
use warnings;
use Data::Dumper;
use LWP::UserAgent;
use Net::PlaysTv;
use POSIX;

#************************************************
# perl ./YouTubeUpload.pl
#************************************************

my $directory = get_input();
$directory = '/usr/SocialMedia/Video/';

my $Playstv = PlaysTv->new('LeagueofLegends', $directory);

get_paystv_video();

sub get_paystv_video {
    my ($attr) = @_;

    $Playstv->playstv_get_video_list();

    my ($date) = strftime("%Y-%m-%d_%H:%M", localtime(time));

    $Playstv->paystv_get_video({ VIDEO_NUM => $ARGV[0], YOTUBE_VIDEO_NAME => $ARGV[1] });

    prepare_and_ulploed_youtube($Playstv->{VIDEOS}[0]);

    $Playstv->{DBI}->disconnect;
    return 1;
}

sub prepare_and_ulploed_youtube {
    my ($name) = @_;

    system(
        "youtube-upload --title='A.S. Mutterj' "
            . $directory
            . $name
            . " --credentials-file=/usr/Video/ZGV --client-secrets=/usr/Downdloed/client_secret.json"
    );

    return 1;
}
