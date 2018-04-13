package Net::Services::Ffmpeg;

use strict;
use warnings FATAL => 'all';

sub mp4_to_mpg {
    my ($name) = @_;

    system("ffmpeg -i $name -qscale $name.mpg");

    return 1
}

sub concatination {
    my ($videos, $outputname) = @_;

    system("cat $videos | ffmpeg -f mpeg -i - -an -qscale 0 -vcodec mpeg4 $outputname");

    return 1
}

1;