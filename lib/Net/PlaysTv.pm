package Net::PlaysTv;

use strict;
use warnings;
use LWP::UserAgent ();
use Data::Dumper;
use DBI;

our $VERSION = '0.01';

my $ua = LWP::UserAgent->new;
$ua->agent('Mozilla/5.0 (Windows NT 6.1; rv=>52.0) Gecko/20100101 Firefox/52.0');

my $dbh = DBI->connect('DBI:mysql:youtube_uploed', 'root', '1234',);
# my $query = "SELECT * FROM mytable";

#    my $mytable_output = $db->prepare($query);
#    $mytable_output->execute;
#    $mytable_output->finish;


sub new {
  my $class     = shift;
  my $game      = shift;
  my $directory = shift;

  my ($attr) = @_;

  my $self = {};
  bless($self, $class);

  $self->{GAME} = $game;
  $self->{DBI}  = $dbh;
  $self->{SAVE_DIRECTORY}  = $directory;
  # foreach my $extra_param (keys %{$attr}){
  #   $self->{$extra_param} = $attr->{$extra_param}
  # }

  return $self;
}

sub playstv_get_video_list {
  my $self = shift;

  my $response = $ua->get("http://plays.tv/game/$self->{GAME}?page=1");

  if($response->is_success){
    my @video = ();
    push @video, $response->{_content} =~ m/video\b\/(\w+)\/processed\/\b.+type\b/g;
    $self->{video_list} = \@video;
    return $self;
  }
  else{
    return 0;
  }

}

sub paystv_get_video {
  my $self = shift;

  my @quality = ( '', '720', '720', '480' );

  #Search link with best quality video

  foreach my $video_id (@{$self->{video_list}}){
    my $response_result = '';
    my $response = '';
    my $i = 1;

    while ( !($response_result || $i == 3) ){
      $response = $ua->get("http://d0playscdntv-a.akamaihd.net/video/$video_id/processed/". $quality[$i++]. ".mp4");
      $response_result = $response->is_success ? $quality[$i-1] : 0;
      print $quality[$i-1] ."\n";
    }

    if ($response->is_success) {
      open(my $fh, '>', "$self->{SAVE_DIRECTORY}$video_id.mp4");
      print "Create file $video_id.mp4\n";
        my $sth = $dbh->prepare("INSERT INTO video(vid, type, created) VALUES (?,?,?)");
      $sth->execute( $video_id, 'playstv', 'NOW()');
      # delete $response->{_content};
      print $fh $response->decoded_content;
      # print Dumper($response);
      close $fh;
      system("ffmpeg -i $self->{SAVE_DIRECTORY}$video_id.mp4 -acodec copy -vcodec copy -vbsf h264_mp4toannexb -f mpegts $self->{SAVE_DIRECTORY}$video_id.ts");
    }

  }

  return 1;
}

# $dbh->disconnect;

1