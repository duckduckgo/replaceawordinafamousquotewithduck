#!/usr/bin/perl 

use strict;
use warnings;

use JSON;
use Data::Dumper;
use IO::Handle;
use Net::Twitter;

my $twitter = Net::Twitter->new(
    traits   => [qw/API::REST API::Search/],
    username => 'duckduckgo',
    password => 'XXXXXXXX'
    );

my $count = 0;

$|++;

my %searches = (
    '#replaceawordinafamousquotewithduck' => undef,
    );


open(OUT,">>/usr/local/ddg/replaceawordinafamousquotewithduck.com/grab.txt");

while (1) {
    print $count++, "\n";

    foreach my $search (keys %searches) {
	
	my $since_id = $searches{$search} || 0;
	my $mentions;
	eval {
	    $mentions = $twitter->search({ q => "$search", since_id => $since_id, lang => 'en' });
	};	
	next if !$mentions;

	# For debugging.
#	print Dumper($mentions);

	foreach my $mention (reverse @{$mentions->{'results'}}) {
	
	    # For debugging.
#	    print Dumper($mention);

	    my $id = $mention->{'id'};
	    my $screen_name = $mention->{'from_user'};
	    next if !$id;
	    $searches{$search} = $id;
	    
	    my $tweet = $mention->{'text'};
	    next if !$tweet;

	    $tweet = clean($tweet);
	    next if $tweet =~ /^(?:\@|RT)/o;
	    next if $tweet =~ /(?:@|http:\/\/)/o;

	    next if length($tweet)<20;

	    print qq($tweet\n);
	    
	    print OUT qq($id\t$screen_name\t$tweet\n);
	    OUT->flush();

	}
    }

    sleep(1);
}
close(OUT);

sub clean {
    my ($str) = @_;

    $str = '' if !$str;

    $str =~ s/[\t\n\r\f]//gso;

    return $str;
}
