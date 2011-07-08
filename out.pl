#!/usr/bin/perl

use strict;
use warnings;

use utf8;
use Encode qw( is_utf8 _utf8_on from_to encode decode :fallbacks );
binmode STDOUT, ":utf8";

use File::Copy;

my %count = ();
my %full = ();
my %dup = ();

open(IN,"</usr/local/ddg/replaceawordinafamousquotewithduck.com/grab.txt");
while (my $line = <IN>) {
    chomp($line);
    my @line = split(/\t/,$line);

    my $id = $line[0];    
    next if exists $dup{$id};
    $dup{id} = undef;

    my $username = $line[1];
    my $tweet = $line[2];

    $tweet =~ s/\#replaceawordinafamousquotewithduck\s*//i;

    my $tweet2 = $tweet;
    $tweet2 =~ s/\#[^\s]+\s*//;
    $tweet2 =~ s/\&quot\;/\"/og;
    $tweet2 =~ s/\&amp\;/\&/g;
    $tweet2 =~ s/\-\-.*//;
    $tweet2 =~ s/^\s*\"//;
    $tweet2 =~ s/\s*\"\s*$//;

    # FOr debugging.
#    print qq($tweet\n);

    $tweet2 = lc $tweet2;
    $tweet2 =~ s/[^a-z]+//g;

    next if !$tweet2;

    $count{$tweet2}++;
    if ($count{$tweet2}>1) {
	$full{$tweet2} = qq($tweet\t$username\t$id);
    }
}

my $lines = '';

foreach my $tweet2 (sort {$count{$b}<=>$count{$a}} keys %count) {
    my $count = $count{$tweet2};
    last if $count<5;

    # For debugging.
#    print $count, "\n";
#    print qq($count\t) . length($tweet2), qq(\t$tweet2\n);

    my ($tweet,$username,$id) = split(/\t/,$full{$tweet2});

     # For debugging.
#    print qq($tweet\t$username\t$id\n);

    $lines .= qq(<div class="tweet">$tweet</div><div class="username">$count tweets; this latest one by <a href="http://twitter.com/$username">\@$username</a></div>);
}


open OUT, ">:encoding(UTF-8)", Encode::decode_utf8("/usr/local/ddg/www-static/replaceawordinafamousquotewithduck.com/index.tmp.html");
print OUT <<EOH
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
 "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
   <title>#replaceawordinafamousquotewithduck</title>
   <link title="DuckDuckGo" type="application/opensearchdescription+xml" rel="search" href="ddg/opensearch.xml">
   <link rel="stylesheet" href="ddg/s99.css" type="text/css">
   <meta http-equiv="refresh" content="180;url=/" /> 
<style type="text/css">
.tweet {
    font-style: italic;
    font-size: 20px;
    padding-bottom: 5px;
}
.username {
    font-size: 12px;
    padding-bottom: 20px;
}
</style>
</head>
<body>

<br><br>
<center>

DuckDuckGo, a search engine that <a href="http://donttrack.us">doesn't track</a> or <a href="http://dontbubble.us">bubble</a> you:
<br><br>
<iframe src="http://duckduckgo.com/search.html?duck=yes" style="overflow:hidden;margin:0;padding:0;width:473px;height:60px;" frameborder="0"></iframe>
</center>

<br><br>
<center>
<table>
<tr>
<td width="260" valign="top" style="padding-right: 50px;">

<script src="http://widgets.twimg.com/j/2/widget.js"></script>
<script>
    new TWTR.Widget({
      version: 2,
      type: 'search',
      search: '#replaceawordinafamousquotewithduck',
      interval: 6000,
      title: '#replaceawordinafamousquotewithduck',
      subject: '',
      width: 250,
      height: 300,
      theme: {
	shell: {
	  background: '#d54249',
	  color: '#ffffff'
	  },
	    tweets: {
	      background: '#ffffff',
	      color: '#444444',
	      links: '#1986b5'
	  }
	},
      features: {
	scrollbar: false,
	loop: true,
	live: true,
	hashtags: true,
	timestamp: true,
	avatars: true,
	toptweets: true,
	behavior: 'default'
	}
		    }).render().start();
</script>

<br><br>
<a href="http://www.facebook.com/duckduckgo?sk=app_4949752878"><img src="wall-e.jpg"></a>
<br><br>
<a href="http://www.facebook.com/duckduckgo?sk=app_4949752878"><img src="inception.jpg"></a>
<br><br>
<a href="http://www.facebook.com/duckduckgo?sk=app_4949752878"><img src="jurassic-park.jpg"></a>
<br><br>
<a href="http://www.facebook.com/duckduckgo?sk=app_4949752878"><img src="twilight.jpg"></a>
<br><br>
<a href="http://www.facebook.com/duckduckgo?sk=app_4949752878"><img src="star-wars.jpg"></a>
<br><br>
<a href="http://www.facebook.com/duckduckgo?sk=app_4949752878"><img src="step-up-4.jpg"></a>
<br><br>
<a href="http://www.facebook.com/duckduckgo?sk=app_4949752878"><img src="spiderman-3.jpg"></a>

</td>
<td width="450" valign="top">
<b>
Top \#ReplaceAWordInAFamousQuoteWithDuck tweets,
updated every 5min, by <a href="http://duckduckgo.com">DuckDuckGo</a> (a search engine).
</b>
<br><br>
$lines
</td>
</tr>
</table>

</center>
</body>
</html>

EOH
    ;

move("/usr/local/ddg/www-static/replaceawordinafamousquotewithduck.com/index.tmp.html","/usr/local/ddg/www-static/replaceawordinafamousquotewithduck.com/index.html");
