package Net::Tags;
use strict;
use warnings FATAL => 'all';
use LWP::UserAgent ();
use Data::Dumper;
use Log::Tiny;
use DBI;

my $log = Log::Tiny->new('../logs/local.log') or
    die 'Could not log! (' . Log::Tiny->errstr . ')';

my $dbh = DBI->connect('DBI:mysql:playstv', 'root', '123',) or
    die $log->ERROR('Cant connect to Date Base!');

sub get_tags {
    my ($attr) = @_;

#    forech my $tag (@tagsw){
#        my $ins = $dbh->prepare("INSERT INTO TABLE Fortnite_tags (name) VALUES (?)");
#        $sth->execute($tag);
#    }

    my $sth = $dbh->prepare("SELECT name FROM $attr->{game}_tags")or
        $dbh->do("
            CREATE TABLE IF NOT EXISTS `$attr->{game}_tags` (
                `id` INTEGER(11) UNSIGNED NOT NULL AUTO_INCREMENT,
                `name` VARCHAR(150) NOT NULL DEFAULT '',
            PRIMARY KEY (`id`),
            UNIQUE KEY `name` (`name`)
            )
            COMMENT = '$attr->{game}_tags table';
         ") or
        die $log->ERROR("Cant connect to table $attr->{game}_tags!");

    my @tags = $sth->execute_array();

    print "\n\n\n". Dumper(\@tags);
}

