#!/usr/bin/perl

use lib '../lib';
use strict;
use warnings;
use Data::Dumper;
use LWP::UserAgent;
use Net::PlaysTv;
use POSIX;

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

my $directory = '/usr/YouTube-script/video/';

my $Playstv = Net::PlaysTv->new('LeagueofLegends', $directory);

get_video();

#************************************************
# perl ./YouTubeUpload.pl
#************************************************
sub get_video {
    my ($attr) = @_;

    $Playstv->playstv_get_video_list();

    my ($date) = strftime("%Y-%m-%d_%H:%M", localtime(time));

    $Playstv->playstv_get_video({ VIDEO_NUM => 2, YOTUBE_VIDEO_NAME => 'test.mpg' });
#    $Playstv->playstv_get_video({ VIDEO_NUM => 2, YOTUBE_VIDEO_NAME => $ARGV[1] });

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
