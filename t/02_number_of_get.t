use strict;
use warnings;
use Net::Natalie;

BEGIN {
  use Test::More;
  use Test::Most tests => 5;
}

my $natalie = Net::Natalie->new( content => 'comic' );

my %fetched = $natalie->fetch_entry_title_manually( 1 );
is( (scalar (keys %fetched)), 1, 'number_of_title' );

%fetched = $natalie->fetch_entry_summary_manually( 2 );
is( (scalar (keys %fetched)), 2, 'number_of_summary' );

%fetched = $natalie->fetch_entry_info_manually( 3 );
is( (scalar (keys %fetched)), 3, 'number_of_info' );

%fetched = $natalie->fetch_entry_info_manually( -1 );
is( (scalar (keys %fetched)), 0, 'number_of_info_nagate' );

dies_ok( sub{ $natalie->fetch_entry_info_manually() } );

done_testing();
