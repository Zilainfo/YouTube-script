package Net::Ffmpeg;

use strict;
use warnings FATAL => 'all';
use Data::Dumper;
use Log::Tiny;

my $log = Log::Tiny->new('../logs/local.log') or
    die 'Could not log! (' . Log::Tiny->errstr . ')';

sub mp4_to_mpg {
    my $self = shift;
    my ($attr) = @_;

    print "\n\n\n". Dumper($attr);


    system("ffmpeg -i $attr->{DIR}.mp4 -c:v mpeg2video -q:v 5 -c:a mp2 -f vob $attr->{DIR}.mpg");
    $log->DEBUG("ffmpeg -i $attr->{DIR}.mp4 -c:v mpeg2video -q:v 5 -c:a mp2 -f vob $attr->{DIR}.mpg");

    return "$attr->{DIR}.mpg";
}

sub concatination {
    my $self = shift;
    my ($videos, $outputname) = @_;

    system("cat $videos | ffmpeg -f mpeg -i - -an -qscale 0 -vcodec mpeg4 $outputname") or
        die "Cant concat";
    $log->DEBUG("cat$videos | ffmpeg -f mpeg -i - -an -qscale 0 -vcodec mpeg4 $outputname");

    return 1
}

1;