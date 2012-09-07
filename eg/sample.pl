#!/usr/bin/env perl

use 5.008;
use strict;
use warnings;
use FindBin;
use lib ("$FindBin::Bin/../lib");

use Net::Natalie;

my $foo = Net::Natalie->new( content => 'comic', get_num => 2 );
my %bar = $foo->fetch_entry_title_by_feed;
foreach ( keys %bar ) {
    print "$bar{$_}: $_\n";
}
