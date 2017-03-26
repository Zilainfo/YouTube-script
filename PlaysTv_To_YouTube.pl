 use strict;
 use warnings;
 use LWP::UserAgent ();

 my $ua = LWP::UserAgent->new;

 $ua->agent('Mozilla/5.0 (Windows NT 6.1; rv=>52.0) Gecko/20100101 Firefox/52.0');

 my @header_request =(
  'Host'                      => 'd0playscdntv-a.akamaihd.net',
  'User-Agent'                => 'Mozilla/5.0 (Windows NT 6.1; rv=>52.0) Gecko/20100101 Firefox/52.0',
  'Accept'                    => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
  'Accept-Language'           => 'ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3',
  'Accept-Encoding'           => 'gzip, deflate',
  'Connection'                => 'keep-alive',
  'Upgrade-Insecure-Requests' => 1,
  'If-Modified-Since'         => 'Sat, 04 Mar 2017 08=>35=>06 GMT',
  'If-None-Match'             => "1e591e934fae64842b963d9343755f1b-1",
  'Cache-Control'             => 'max-age=0',
);

 my $response = $ua->get('http://d0playscdntv-a.akamaihd.net/video/GlijJJRuM6h/processed/720.mp4', @header_request);

 # my $response = $ua->get('http://search.cpan.org/', @header_request);

 if ($response->is_success) {
     # use Data::Dumper;
     open(my $fh, '>', 'video.mp4');
     # print Dumper($response);
     print $fh $response->decoded_content;
     # print $response->status_line;  # or whatever
 }
 else {
     die $response->status_line;
 }