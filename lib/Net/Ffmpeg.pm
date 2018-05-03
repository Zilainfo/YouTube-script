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

    $log->DEBUG('ffmpeg -i concat:"$videos" -c copy $outputname');

    system("ffmpeg -i concat:\"$videos\" -c copy $outputname") or
        die "Cant concat";

    return 1
}

1;