#!/usr/bin/perl

use strict;
use warnings;
use JSON::Parse 'json_file_to_perl';
use Data::Dumper;
use DateTime;
#use Date::Manip;

# define default runtime vars
my $filename = $ARGV[0];
my $destfilename = $filename.".new";
my $erxnodes = "";
my $nodecounter_max = 0;
my $nodesfound = 0;
# my $filename = "nodes.json";

$erxnodes = "b4fbe4b1ac44";

if ( ! $filename ) {
                print "USAGE: ./jsondump.pl <filename>\n";
                exit 0;
        }

# test, if file exist
if ( -f $filename ){

# Parse JSON data
 # Read JSON data from FILE
        my $content = json_file_to_perl ($filename);
        # print Dumper($content);

## MAIN Loop
       foreach my $key ( keys %$content ) {
            if ( $key eq 'nodes' ){
                           $nodesfound=1;
                #       foreach my @node
              } # if key nodes
        } # foreach keys
            if ( $nodesfound ) {
                print "found nodes array...\n";

                open(my $nl, '>', $destfilename) || die $!;

                        while ( $content->{'nodes'}->[$nodecounter_max] ){
                           # just count to max values
                           # print $nodecounter_max.": ".$content->{'nodes'}->[$nodecounter_max]->{'nodeinfo'}->{'node_id'}."\n";
                           $nodecounter_max++;
                        }
                        $nodecounter_max --;
                        # print "Records: ".$nodecounter_max."\n";

        ## Inner Loop
                 # Process array for each of nodecounter-max nodes:
                for (my $i = 0; $i < $nodecounter_max; $i++){
                        # Nodes value parsing

                        print $content->{'nodes'}->[$i]->{'statistics'}->{'node_id'}.':';
                        print $content->{'nodes'}->[$i]->{'statistics'}->{'clients'}.' ';


                }
        ## End Inner Loop
                close ($nl);

                }

## End MAIN Loop

} else {
                        print "ERROR: file ".$filename." does not exist.\n";
}


exit 0;
