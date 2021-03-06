#!/usr/bin/perl
use strict;
use JSON;
use POSIX qw(strftime);

my $node_json_file = "/opt/data/mobilemeshviewer/nodes_v1.json";
my $wifi_analyzer_alias_file= "/opt/data/mobilemeshviewer/WifiAnalyzer_Alias.txt";
my $nodecounter = 0;
my $maxrecords = 0;
# Timestamp Format 2019-02-15T02:22:16+0100
my $date = strftime "%Y-%m-%d", localtime;
my $time = strftime "%H:%M:%S", localtime;
my $timestamp= $date."T".$time."+0100";

main();

sub main {
        my $node_json = &get_node_json();
        for my $node(keys %{$node_json->{'nodes'}}) {
          $maxrecords++;
        }
        open(my $wa, '>', $wifi_analyzer_alias_file) || die $!;
        # print "Records: ".$maxrecords;
        for my $node(keys %{$node_json->{'nodes'}}) {
           my $nodename =  $node_json->{'nodes'}->{$node}->{'nodeinfo'}->{'hostname'};
           # print "nodename: ".$nodename."\n";
           if ( $node_json->{'nodes'}->{$node}->{'nodeinfo'}->{'network'}->{'mesh'}->{'bat0'}->{'interfaces'}->{'wireless'}->[0] ) {
                # mesh0 mac is not, what we want - lets substract 1 to get wifi ap interface mac
                my $mac = $node_json->{'nodes'}->{$node}->{'nodeinfo'}->{'network'}->{'mesh'}->{'bat0'}->{'interfaces'}->{'wireless'}->[0];
                my $mac_prefix = substr($mac,0,15);
                my $mac_end = substr($mac,15,2);
                my $mac_calc = hex($mac_end);
                my $mac_int  = int($mac_calc);
                $mac_int --;
                my $mac_new = sprintf("%x", $mac_int);
                if ( length($mac_new) < 2) {
                   $mac_new = "0".$mac_new;
                }
                print $wa $mac_prefix.$mac_new."|Freifunk_".$nodename."\n";
                # print "wifi0: ".$mac." ".$mac_prefix.$mac_new."\n";
           }
           if ( $node_json->{'nodes'}->{$node}->{'nodeinfo'}->{'network'}->{'mesh'}->{'bat0'}->{'interfaces'}->{'wireless'}->[1] ) {
                # mesh1 mac is not, what we want - lets substract 1 to get wifi ap interface mac
                my $mac = $node_json->{'nodes'}->{$node}->{'nodeinfo'}->{'network'}->{'mesh'}->{'bat0'}->{'interfaces'}->{'wireless'}->[1];
                my $mac_prefix = substr($mac,0,15);
                my $mac_end = substr($mac,15,2);
                my $mac_calc = hex($mac_end);
                my $mac_int = int($mac_calc);
                $mac_int --;
                my $mac_new = sprintf("%x", $mac_int);
                 if ( length($mac_new) < 2) {
                   $mac_new = "0".$mac_new;
                }

                print $wa $mac_prefix.$mac_new."|Freifunk_".$nodename."\n";
                # print "wifi1: ".$mac." ".$mac_prefix.$mac_new."\n";

           }
           $nodecounter++;

        }
}

sub write_json {
        my($json) = @_;

        open(my $fh, '>', $node_json_file) || die $!;
        print $fh to_json($json);
        close($fh);
}

sub get_node_json {
        open(my $fh, '<', $node_json_file) || die $!;
        my $json_data = join('',<$fh>);
        close($fh);

        return from_json($json_data);
}


