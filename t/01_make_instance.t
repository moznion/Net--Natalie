use strict;
use warnings;
use Net::Natalie;

BEGIN {
  use Test::Most tests => 4;
}

lives_ok( sub { Net::Natalie->new( content => 'comic' ) } );

lives_ok( sub { Net::Natalie->new( content => 'music' ) } );

lives_ok( sub { Net::Natalie->new( content => 'owarai' ) } );

dies_ok( sub { Net::Natalie->new( content => 'foo' ) } );

done_testing();
