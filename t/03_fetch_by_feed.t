use strict;
use warnings;
use Net::Natalie;

BEGIN {
  use Test::Most tests => 3;
}

my $natalie = Net::Natalie->new( content => 'comic' );

lives_ok( sub { $natalie->fetch_entry_title_by_feed } );

lives_ok( sub { $natalie->fetch_entry_summary_by_feed } );

lives_ok( sub { $natalie->fetch_entry_info_by_feed } );

done_testing();
