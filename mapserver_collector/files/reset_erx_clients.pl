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
my @erxnodes = "";
my $erxcount = 0;
my $erx = "";
my $nodecounter_max = 0;
my $nodesfound = 0;
my $nodeid ="";
my $nodeclients=0;
# my $filename = "nodes.json";

@erxnodes = "b4fbe4b1ac44";

if ( ! $filename ) {
                print "USAGE: ./reset_erx_clients.pl <filename>\n";
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
                        print "Records: ".$nodecounter_max."\n";

        ## Inner Loop
                 # Process array for each of nodecounter-max nodes:
                for (my $i = 0; $i < $nodecounter_max; $i++){
                        # Nodes value parsing

                        $nodeid =  $content->{'nodes'}->[$i]->{'statistics'}->{'node_id'};
                        $nodeclients = $content->{'nodes'}->[$i]->{'statistics'}->{'clients'};

                        # check if nodeid is ione of erxnodes
                        $erxcount = 0;
                        foreach $erx (@erxnodes) {
                                ## matching nodeid = erxnode ?
                                ## print 'searching for '.$erx.' ...';
                                if ($nodeid eq $erx){
                                  # print 'fount matching node '.$nodeid.;
                                  # lets set clientcounter to 0
                                  print 'Setting Clients for '.$nodeid.' from '.$nodeclients.' to 0'."\n";
                                  $content->{'nodes'}->[$i]->{'statistics'}->{'clients'}=0;
                                }
                        }


                }

                ## debug content after processing

                 # Process array for each of nodecounter-max nodes:
                for (my $i = 0; $i < $nodecounter_max; $i++){
                        # Nodes value parsing

                        $nodeid =  $content->{'nodes'}->[$i]->{'statistics'}->{'node_id'};
                        $nodeclients = $content->{'nodes'}->[$i]->{'statistics'}->{'clients'};

                        print $nodeid.':'.$nodeclients."\n";

                }
        ## End Inner Loop
                close ($nl);

                }

## End MAIN Loop

} else {
                        print "ERROR: file ".$filename." does not exist.\n";
}


exit 0;

