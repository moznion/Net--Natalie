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
        } elsif ( $type eq 'info' ) {
            my @info;
            push( @info, $entry->title );
            push( @info, $entry->summary->body );
            $titles{$entry->link} = \@info;
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

sub fetch_entry_info_by_feed {
    my ( $this ) = @_;
    return $this->__parse_feed_by( 'info' );
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
            } elsif ( $type eq 'info' ) {
                my @info;
                $res->content =~ m#<title>(.*)</title>#;
                push( @info, $1 );
                $res->content =~ m#<div id="news-text">.*\r?\n?.*<p>(.*)</p>#;
                push( @info, $1 );
                $titles{$uri} = \@info;
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

sub fetch_entry_info_manually {
    my ( $this, $num_of_entry_to_get ) = @_;
    die "Please specify the 'num_of_entry_to_get' by parameter." unless $num_of_entry_to_get;

    return $this->__parse_manually_by( 'info', $num_of_entry_to_get );
}

1;
__END__

=head1 NAME

Net::Natalie - Natalie (http://natalie.mu) API(?) Wrapper

=head1 SYNOPSIS

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

=head1 DESCRIPTION

Net::Natalie is a wrapper of Natalie API.

=head1 INSTALL

Download it && Unpack it && Build it
As follows:
    % perl Makefile.PL
    % make && make test  # <= Required Internet connection
    % make install

=head1 METHODS

=head2 new( %param )

Make an instance of Net::Natalie.
This method require a content type to fetch.
e.g.)
  new( content => 'comic' );

Available content type are following:
  - comic
  - music
  - owarai

=head2 fetch_entry_title_manually( $num_of_get_entry )
This method get titles of entries by http query up to $num_of_get_entry from recent entry.
It returns a hash. (URL => title)

=head2 fetch_entry_summary_manually( $num_of_get_entry )
This method get summaries of entries by http query up to $num_of_get_entry from recent entry.
It returns a hash. (URL => summary)

=head2 fetch_entry_info_manually( $num_of_get_entry )
This method get titles and summaries of entries by http query up to $num_of_get_entry from recent entry.
It returns a hash. (URL => (title, summary))

=head2 fetch_entry_title_by_feed
This method get titles of entries by rss feed. (Maybe up to 50 entries)
It returns a hash. (URL => title)

=head2 fetch_entry_summary_by_feed
This method get summaries of entries by rss feed.
It returns a hash. (URL => summary)

=head2 fetch_entry_info_by_feed
This method get titles and summaries of entries by rss feed.
It returns a hash. (URL => (title, summary))

=head1 AUTHOR

moznion E<lt>moznion@gmail.com<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
