#!/usr/bin/perl

#use strict;
#use warnings;
use Web::Scraper;
use URI;
use HTML::Entities;
use Encode;
use URI::Escape;
use LWP::UserAgent;

my $scrap;

my $wikiurl = "http://www.bildung-lsa.de/unterricht/zentrale_leistungserhebungen__schriftliche_pruefungen__zentrale_klassenarbeiten__vergleichsarbeiten____/schriftliche_abiturpruefung.html";

my $ua = new LWP::UserAgent;
my $req = HTTP::Request->new('GET', $wikiurl);
my $res = $ua->request($req);
my $url = $res->request->uri;

binmode(STDOUT, ":utf8");


   $scrap = scraper {
      process '//a[@class="subjectlink"]', 'href[]' => '@href';
   };
   $url = URI->new($wikiurl);

   my $res = $scrap->scrape($url);
   my $href = $res->{'href'};
   for ($i = 0; $i <= $#$href; $i++)
   {
         my $url = $$href[$i];
         system("wget -q \"$url\"");
   }
