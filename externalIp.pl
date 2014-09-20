#!/usr/bin/perl

($ip=`wget -q -O - http://checkip.dyndns.org`)=~s/\n$//;
$ip=~s/.*[^\d](\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})[^\d].*/$1/;
($date=`date`)=~s/\n$//;
print "$date\n$ip\n";
