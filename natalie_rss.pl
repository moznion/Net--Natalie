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
my $base_uri = "http://natalie.mu/$content_name/news";
my $rss_uri  = "http://natalie.mu/$content_name/feed/news";
my $feed = XML::Feed->parse(URI->new($rss_uri)) or die XML::Feed->errstr;

my $latest_serial = 0;
foreach my $entry ($feed->entries) {
    $entry->link =~ m#/(\d*)$#;
    if ($1 > $latest_serial) {
        $latest_serial = $1;
    }
}

my $number_of_wanna_get = 10; #TODO This variable should be set by the constructor.
my $furl = Furl->new(
    agent => 'foo', #FIXME set correctly agent name
    timeout => 10
);
for (my $iter = 0, my $ratio = 0; $iter < $number_of_wanna_get; $ratio++) {
    my $serial_number = $latest_serial - $ratio;
    my $res = $furl->get("$base_uri/$serial_number");
    if ($res->content =~ m#<meta property="og:url".*/$content_name/#) {
        $res->content =~ m#<title>(.*)</title>#;
        print "$1\n";
        $iter++;
    }
}
