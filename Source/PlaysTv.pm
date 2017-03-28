package PlaysTv;

use strict;
use LWP::UserAgent ();
use Data::Dumper;

my $ua = LWP::UserAgent->new;
$ua->agent('Mozilla/5.0 (Windows NT 6.1; rv=>52.0) Gecko/20100101 Firefox/52.0');

sub new {
  my $class  = shift;
  my $game   = shift;
  my ($attr) = @_;

  my $self = {};
  bless($self, $class);

  $self->{GAME} = $game;

  # foreach my $extra_param (keys %{$attr}){
  #   $self->{$extra_param} = $attr->{$extra_param}
  # }

  return $self;
}

sub playstv_get_video_list {
  my $self = shift;
  my ($attr) = @_;

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
  my ($attr) = @_;

  my @quality = ( '', '1080', '720', '480' );
  my $response_result = '';
  my $response = '';

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
      # open(my $fh, '>', 'video.mp4');
      # delete $response->{_content};
      # print $fh $response->decoded_content;
      # print Dumper($response);
    }

  }

  return 1;
}


1