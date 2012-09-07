#!/usr/bin/env perl

use 5.008;
use strict;
use warnings;
use URI;
use utf8;
use Encode;
use XML::Feed;
use Furl;

my $content_name = 'comic'; #TODO This variable should be set by the constructor. This is mock-up.
unless ($content_name =~ /comic|music|owarai/) {
    die "Natalie does not have such content : $content_name";
}
my $uri  = "http://natalie.mu/$content_name/feed/news";
my $feed = XML::Feed->parse(URI->new($uri)) or die XML::Feed->errstr;

my $latest_uri;
my $latest_serial = 0;
foreach my $entry ($feed->entries) {
    $entry->link =~ m#/(\d*)$#;
    if ($1 > $latest_serial) {
        $latest_serial = $1;
        $latest_uri    = $entry->link;
    }
}

my $furl = Furl->new(
    agent => 'foo', #FIXME set correctly agent name
    timeout => 10
);
my $res = $furl->get($latest_uri);

if ($res->content =~ m#<meta property="og:url".*/$content_name/#) {
    say 'yes';
}
