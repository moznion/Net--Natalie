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

__PACKAGE__->mk_accessors( qw( content base_uri feed ) );

sub new {
    my ( $class, %opts ) = @_;

    unless ( $opts{content} ) {
        die "Please specify the content name. (e.g. 'music')";
    }
    unless ( $opts{content} =~ /comic|music|owarai/ ) {
        die "Natalie does not have such content : $opts{content}";
    }

    $opts{base_uri} ||= "http://natalie.mu/$opts{content}/news";
    $opts{feed}     ||= XML::Feed->parse(
        URI->new( "http://natalie.mu/$opts{content}/feed/news" )
    );

    my $this = $class->SUPER::new( { %opts } );
    return $this;
};

sub get_latest_entry_serial {
    my ( $this ) = @_;

    my $latest_serial = 0;
    foreach my $entry ( $this->feed->entries ) {
        $entry->link =~ m#/(\d*)$#;
        if ( $1 > $latest_serial ) {
            $latest_serial = $1;
        }
    }

    return $latest_serial;
}

sub __parse_feed_by {
    my ( $this, $type ) = @_;

    my %titles;
    foreach my $entry ( $this->feed->entries ) {
        if ( $type eq 'title' ) {
            $titles{$entry->link} = $entry->title;
        } elsif ( $type eq 'summary' ) {
            $titles{$entry->link} = $entry->summary->body;
        } else {
            die "Not supported type : $type";
        }
    }
    return %titles;
}

sub fetch_entry_title_by_feed {
    my ( $this ) = @_;
    return $this->__parse_feed_by( 'title' );
}

sub fetch_entry_summary_by_feed {
    my ( $this ) = @_;
    return $this->__parse_feed_by( 'summary' );
}

sub __parse_manually_by {
    my ( $this, $type, $num_of_entry_to_get ) = @_;
    die "Please specify the 'num_of_entry_to_get' by parameter." unless $num_of_entry_to_get;

    my $latest_serial = $this->get_latest_entry_serial;

    my $furl = Furl->new(
        agent => 'foo', #FIXME set correctly agent name
        timeout => 10
    );

    my %titles;
    my $iter  = 0;
    my $ratio = 0;
    while ( $iter < $num_of_entry_to_get ) {
        my $serial_number = $latest_serial - $ratio;
        my $base_uri = $this->base_uri;
        my $uri = "$base_uri/$serial_number";
        my $res = $furl->get( $uri );
        my $content = $this->content;
        if ( $res->content =~ m#<meta property="og:url".*/$content/# ) {
            if ( $type eq 'title' ) {
                $res->content =~ m#<title>(.*)</title>#;
                $titles{$uri} = $1;
            } elsif ( $type eq 'summary' ) {
                $res->content =~ m#<div id="news-text">.*\r?\n?.*<p>(.*)</p>#;
                $titles{$uri} = $1;
            } else {
                die "Not supported type : $type";
            }
            $iter++;
        }
        $ratio++;
    }
    return %titles;
}

sub fetch_entry_title_manually {
    my ( $this, $num_of_entry_to_get ) = @_;
    die "Please specify the 'num_of_entry_to_get' by parameter." unless $num_of_entry_to_get;

    return $this->__parse_manually_by( 'title', $num_of_entry_to_get );
}

sub fetch_entry_summary_manually {
    my ( $this, $num_of_entry_to_get ) = @_;
    die "Please specify the 'num_of_entry_to_get' by parameter." unless $num_of_entry_to_get;

    return $this->__parse_manually_by( 'summary', $num_of_entry_to_get );
}
1;
