#!/usr/bin/env perl

use 5.008;
use strict;
use warnings;
use FindBin;
use lib ("$FindBin::Bin/../lib");

use Net::Natalie;

my $foo = Net::Natalie->new( content => 'comic' );

my %bar = $foo->fetch_entry_info_manually(2); #Get 2 entries by http query
foreach ( keys %bar ) {
    print "$bar{$_}->[0]: $bar{$_}->[1] -- $_\n"; #<title of entry>: <summary of entry> -- <URL>
}

my %baz = $foo->fetch_entry_info_by_feed; #Get entries by rss feed. (Maybe, it takes 50 entries)
foreach ( keys %baz ) {
    print "$baz{$_}->[0]: $baz{$_}->[1] -- $_\n"; #<title of entry>: <summary of entry> -- <URL>
}
