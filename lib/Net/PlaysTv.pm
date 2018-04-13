package Net::PlaysTv;

use strict;
use warnings;
use LWP::UserAgent ();
use Data::Dumper;
use DBI;
use Net::Services::Ffmpeg;

my $ua = LWP::UserAgent->new;
$ua->agent('Mozilla/5.0 (Windows NT 6.1; rv=>52.0) Gecko/20100101 Firefox/52.0');

my $dbh = DBI->connect('DBI:mysql:youtube_uploed', 'root', '1234',);


sub new {
    my $class = shift;
    my $item = shift;
    my $directory = shift;

    my ($attr) = @_;

    my $self = {};
    bless($self, $class);

    $self->{ITEM} = $item;
    $self->{DBI} = $dbh;
    $self->{SAVE_DIRECTORY} = $directory;
    $self->{MPG_FORMAT} = 1;

    return $self;
}

sub playstv_get_video_list {
    my $self = shift;
    my ($attr) = @_;

    my $response = $ua->get("http://plays.tv/game/$self->{ITEM}?page=1");

    if ($response->is_success) {
        my @video = ();
        push @video, $response->{_content} =~ m/video\b\/(\w+)\/processed\/\b.+type\b/g;
        $self->{video_list} = \@video;
        return $self;
    }
    else {
        return 0;
    }

}

sub paystv_get_video {
    my $self = shift;
    my ($attr) = @_;

    my @quality = ('', '720', '720', '480');
    my $response_result = '';
    my $response = '';

    #Search link with best quality video
    my $videos_string;

    foreach my $video_id (@{$self->{video_list}}) {
        if ($attr->{VIDEO_NUM} && $self->{last_video_num} == $attr->{VIDEO_NUM}) {
            last;
        }

        my $response_result = '';
        my $response = '';
        my $i = 1;

        while (!($response_result || $i == 3)) {
            $response = $ua->get("http://d0playscdntv-a.akamaihd.net/video/$video_id/processed/" . $quality[$i++] . ".mp4");
            $response_result = $response->is_success ? $quality[$i - 1] : 0;
            print $quality[$i - 1] . "\n";
        }

        my $sth = $dbh->prepare("SELECT id FROM video WHERE vid=?");
        $sth->execute($video_id);
        my $resulere = $sth->fetchrow_hashref;

        if ($response->is_success && !$resulere->{id}) {
            open(my $fh, '>', "$self->{SAVE_DIRECTORY}$video_id.mp4");
            print "Create file $video_id.mp4\n";
            $self->{VIDEOS}[$self->{last_video_num}++] = "$video_id.mp4";
            my $sth = $dbh->prepare("INSERT INTO video(vid,type, created) VALUES (?,?,?)");
            $sth->execute($video_id, 'playstv', 'NOW()');

            print $fh $response->decoded_content;

            close $fh;

            if ($self->{MPG_FORMAT}) {
                mp4_to_mpg("$self->{SAVE_DIRECTORY}$video_id");
            }
            print " $self->{SAVE_DIRECTORY}$video_id.mpg " . "\n";

            $videos_string .= " $self->{SAVE_DIRECTORY}$video_id.mpg ";

        }
    }

    my $sth = $dbh->prepare("SELECT num FROM youtube_video WHERE vid=?");
    $sth->execute($attr->{YOTUBE_VIDEO_NAME});
    my $video_num;

    my $query_result = $sth->fetchrow_hashref;
    if ($query_result->{num}) {
        $video_num = ++$query_result->{num};

    }
    else {
        $video_num = 1;
        $sth = $dbh->prepare("INSERT INTO youtube_video(vid, num, created) VALUES (?,?,?)");
        $sth->execute($attr->{YOTUBE_VIDEO_NAME}, $video_num, 'NOW()');
    }

    concatination($videos_string, "$self->{SAVE_DIRECTORY}$attr->{YOTUBE_VIDEO_NAME} #$video_num.mpg");

    $sth = $dbh->prepare("UPDATE youtube_video SET num=? WHERE vid=?");
    $sth->execute($video_num, 'NOW()');

    print " NAME=$self->{SAVE_DIRECTORY}$attr->{YOTUBE_VIDEO_NAME} #$video_num.mpg" . "\n";

    return 1;
}

1