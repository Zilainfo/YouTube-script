#!/usr/bin/perl

use lib '../lib';
use strict;
use warnings;
use Data::Dumper;
use LWP::UserAgent;
use Net::PlaysTv;
use POSIX;
use Getopt::Long;
use Net::Tags;

=head1 NAME
  Simple script
=head1 VERSION
  0.01
=head1 SYNOPSIS
  ytbot.pl - script for.
  Arguments:
    --config,     path to a config file in 'key=value\n' style
    --user
    --password
    --debug
=head1 PURPOSES
  - Deploy application
  - Start application
  - Check if application works and responses
  - Undeploy application
  - Check if application no longer available
=cut

use v5.16;
our $VERSION = 0.01;

our %ATTR = (
    dir => '/usr/YouTube-script/video/',

);

GetOptions (
    'gameid=s'  => \$ATTR{gameid},
    'vnumber=s' => \$ATTR{vnumber},
    'game=s'    => \$ATTR{game},
    'dir=s'     => \$ATTR{dir},
    'name=s'    => \$ATTR{name},
    'token=s'   => \$ATTR{token},
)
    or die("Error in command line arguments\n");
print Dumper(\%ATTR)."\n\n";

get_tags($ATTR{game});
return 1;

my $Playstv = Net::PlaysTv->new($ATTR{game}, $ATTR{dir}, $ATTR{gameid});

get_video();

#************************************************
# perl ./YouTubeUpload.pl
#************************************************
sub get_video {
    my ($attr) = @_;

    $Playstv->playstv_get_video_list();

    my ($date) = strftime("%Y-%m-%d_%H:%M", localtime(time));

    $ATTR{name} = $Playstv->playstv_get_video({ VIDEO_NUM => $ATTR{vnumber}, YOTUBE_VIDEO_NAME => $ATTR{name}, GAME_ID => $ATTR{gameid} });

    my $tags_str = get_tegs($ATTR{game});

    uploed($ATTR{name});

    $Playstv->{DBI}->disconnect;
    return 1;
}

sub uploed {
    my ($name) = @_;

    system(
        "youtube-upload --title='$name' "
            . "\'$ATTR{dir}$name.mpg\'"
            . " --credentials-file=$ATTR{token} --client-secrets=/usr/Downdloed/client_secret.json"
    );

    return 1;
}
#youtube-upload --title='A.S. Mutterj'  test.mpg --credentials-file=/usr/Video/ZGV --client-secrets=/usr/Downdloed/client_secret.json
#perl YouTubeUpload.pl --dir '/usr/YouTube-script/video/' --vnumber 2 --game 'Fortnite' --name 'WTF Fortnite Moments' --token '/usr/YouTube-script/tokens/FortniteWTF' --gameid 98ff5053ea366a4965ba7dbcfa10670c



#Добавить Теги