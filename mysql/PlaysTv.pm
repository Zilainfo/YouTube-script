package PlaysTv;
use mysql::main;

=head1 NAME

  Periodic fess managment functions

=cut

use strict;
our $VERSION = 2.00;

my $MODULE = 'PlaysTv';
my ($admin, $CONF);
my ($SORT, $DESC, $PG, $PAGE_ROWS);

#**********************************************************
# Init
#**********************************************************
sub new{
  my $class = shift;
  my $db = shift;
  ($admin, $CONF) = @_;

  my $self = { };
  bless( $self, $class );


  $self->{db} = $db;
  $self->{admin} = $admin;
  $self->{conf} = $CONF;

  return $self;
}
1