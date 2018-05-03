package Net::PlaysTv;

use strict;
use warnings;
use LWP::UserAgent ();
use Data::Dumper;
use DBI;
use Net::Ffmpeg;
use Log::Tiny;

my $log = Log::Tiny->new('../logs/local.log') or
    die 'Could not log! (' . Log::Tiny->errstr . ')';

my $ua = LWP::UserAgent->new;
$ua->agent('Mozilla/5.0 (Windows NT 6.1; rv=>52.0) Gecko/20100101 Firefox/52.0');

my $dbh = DBI->connect('DBI:mysql:playstv', 'root', '123',) or
    die $log->ERROR('Cant connect to Date Base!');

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

    my $response = $ua->get("http://plays.tv/game/$self->{ITEM}?page=1") or
        die $log->ERROR('Cant get Playlist');

    if ($response->is_success) {
        my @video = ();
        push @video, $response->{_content} =~ m/video\b\/(\w+)\/processed\/\b.+type\b/g;
        $self->{video_list} = \@video;
        $log->INFO('+ Get Playlist');

        return $self;
    }
}

sub playstv_get_video {
    my $self = shift;
    my ($attr) = @_;

    my $videos_string = '';
    $self->{last_video_num} = 0;

    foreach my $video_id (@{$self->{video_list}}) {
        if ($attr->{VIDEO_NUM} && $self->{last_video_num} == $attr->{VIDEO_NUM}) {
            last;
        }

        my $download_res;
        ($self, $download_res) = _playstv_download_video($self, $video_id);

        if($videos_string) {
            $videos_string .= $download_res ? "|$download_res" : '';
        }else{
            $videos_string .= $download_res ? " $download_res" : '';
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

    Net::Ffmpeg->concatination($videos_string, "$self->{SAVE_DIRECTORY}$attr->{YOTUBE_VIDEO_NAME} #$video_num.mpg");

    $sth = $dbh->prepare("UPDATE youtube_video SET num=? WHERE vid=?");
    $sth->execute($video_num, 'NOW()');

    $log->INFO(" NAME=$self->{SAVE_DIRECTORY}$attr->{YOTUBE_VIDEO_NAME} #$video_num.mpg");

    return 1;
}

sub _playstv_download_video {
    my $self = shift;
    my ($vid) = @_;

    my @quality = ('1080', '720');
    my $response_result = '';
    my $response = '';

    #Search link with best quality video
    my $directory;
    my $i = 0;

    while ( $response_result and $i >= $#quality ) {
        $response = $ua->get("http://d0playscdntv-a.akamaihd.net/video/$vid/processed/" . $quality[$i++] . ".mp4") or
            die $log->ERROR('Cant download video');

        $response_result = $response->is_success ? 0 : 1;
    }

    my $sth = $dbh->prepare("SELECT id FROM video WHERE vid=?");
    $sth->execute($vid);
    my $resulere = $sth->fetchrow_hashref;

    if ($response->is_success && !$resulere->{id}) {
        open(my $fh, '>', "$self->{SAVE_DIRECTORY}$vid.mp4");

        print $fh $response->decoded_content;

        $log->INFO("Create file $self->{SAVE_DIRECTORY}$vid.mp4");
        $self->{VIDEOS}[$self->{last_video_num}++] = "$vid.mp4";
        my $sth = $dbh->prepare("INSERT INTO video(vid,type, created) VALUES (?,?,?)");
        $sth->execute($vid, 'playstv', 'NOW()');

        $log->DEBUG("$fh $response->decoded_content");

        close $fh;

        if ($self->{MPG_FORMAT}) {

            $directory = Net::Ffmpeg->mp4_to_mpg( {DIR => "$self->{SAVE_DIRECTORY}$vid"});
        }

        $log->INFO($directory);

        $log->INFO("
            VID            -- $vid\n
            Save directory -- $directory\n
            Video URL      -- http://d0playscdntv-a.akamaihd.net/video/$vid/processed/$quality[$i].mp4\n
            Quality        -- $quality[$i]\n
        "); 
        
        return $self, $directory;
    }

    return $self;
}

1