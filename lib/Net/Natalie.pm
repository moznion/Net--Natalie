package Net::Natalie;

use 5.008;
use strict;
use warnings;
our $VERSION = 0.01;

use parent 'Class::Accessor::Fast';

use URI;
use utf8;
use Encode;
use XML::Feed;
use Furl;

__PACKAGE__->mk_accessors( qw( content get_num base_uri feed ) );

sub new {
    my ($class, %opts) = @_;

    unless ( $opts{content} ) {
        die "Please specify the content name. (e.g. 'music')";
    }
    unless ( $opts{content} =~ /comic|music|owarai/ ) {
        die "Natalie does not have such content : $opts{content}";
    }

    $opts{base_uri} ||= "http://natalie.mu/$opts{content}/news";
    $opts{feed}     ||= XML::Feed->parse(
        URI->new("http://natalie.mu/$opts{content}/feed/news")
    );

    my $self = $class->SUPER::new( { %opts } );
    return $self;
};

sub get_latest_entry_serial {
    my ( $self ) = @_;

    my $latest_serial = 0;
    foreach my $entry ( $self->feed->entries ) {
        $entry->link =~ m#/(\d*)$#;
        if ( $1 > $latest_serial ) {
            $latest_serial = $1;
        }
    }

    return $latest_serial;
}

sub fetch_by_feed {
    my ( $self ) = @_;

    foreach my $entry ( $self->feed->entries ) {
        print $entry->title . "\n";
    }
}

sub fetch_mannually {
    my ( $self ) = @_;

    my $latest_serial = $self->get_latest_entry_serial;

    my $furl = Furl->new(
        agent => 'foo', #FIXME set correctly agent name
        timeout => 10
    );

    my $iter  = 0;
    my $ratio = 0;
    while ($iter < $self->get_num) {
        my $serial_number = $latest_serial - $ratio;
        my $base_uri = $self->base_uri;
        my $res = $furl->get("$base_uri/$serial_number");
        my $content = $self->content;
        if ($res->content =~ m#<meta property="og:url".*/$content/#) {
            $res->content =~ m#<title>(.*)</title>#;
            print "$1.\n";
            $iter++;
        }
        $ratio++;
    }
}

sub main {
    my ( $self ) = @_;

    if ( $self->get_num ) {
        $self->fetch_mannually;
    } else {
        $self->fetch_by_feed;
    }
}
1;
