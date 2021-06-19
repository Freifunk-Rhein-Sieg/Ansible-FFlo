#!/usr/bin/perl

use strict;
use warnings;
use JSON::Parse 'json_file_to_perl';
use JSON;
use Data::Dumper;
use DateTime;
#use Date::Manip;
use File::Copy;

# define default runtime vars
my $filename = $ARGV[0];
my $destfilename = $filename.".new";
my $created_on;
my @erxnodes = "";
my $erxcount = 0;
my $erx = "";
my $nodecounter_max = 0;
my $nodesfound = 0;
my $nodeid ="";
my $nodeclients=0;
my $jsontext;
# my $filename = "nodes.json";

@erxnodes = ('b4fbe4b1ac44', '7483c208d30e','7483c2f65916');

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
          ### Timestamp
             # print $key, " => ", $content->{$key},"\n";
             if ( $key eq 'timestamp' ){
               print "timestamp found : ";
               $created_on = $content->{$key};
               print $created_on."\n";

               # lets check date
               my $today = DateTime->now();
               print "current date: ".$today."\n";

               # lets convert timestamp string to DateTime-Format

                my $year = substr ($created_on,0,4);
                my $month = substr ($created_on,5,2);
                my $day = substr ($created_on,8,2);
                my $hour = substr ($created_on,11,2);
                my $minute = substr ($created_on,14,2);
                my $second = substr ($created_on,17,2);

               print "Date: ".$year."-".$month."-".$day." ".$hour.":".$minute.":".$second."\n";

                    my $filedate = DateTime->new(
                        year      => $year,
                        month     => $month,
                        day       => $day,
                        hour      => $hour,
                        minute    => $minute,
                        second    => $second,
                        time_zone => 'local',
                );


               print "converted: ".$filedate."\n";
                my $days = $filedate->delta_days($today)->delta_days;

               print "Days difference: ".$days."\n";

               if ( $days > 1 ){
                        print "... sending alert...\n";
               }

              } # if key timestamp


          #### NODES
            if ( $key eq 'nodes' ){
                           $nodesfound=1;
                #       foreach my @node
              } # if key nodes
        } # foreach keys
            if ( $nodesfound ) {
                print "found meshview nodes array...\n";

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

                        $nodeid =  $content->{'nodes'}->[$i]->{'node_id'};
                        $nodeclients = $content->{'nodes'}->[$i]->{'clients'};

                        # check if nodeid is ione of erxnodes
                        $erxcount = 0;
                        foreach $erx (@erxnodes) {
                                ## matching nodeid = erxnode ?
                                 print 'searching for '.$erx." ...\n";
                                if ($nodeid eq $erx){
                                  # print 'fount matching node '.$nodeid.;
                                  # lets set clientcounter to 0
                                  print 'Setting Clients for '.$nodeid.' from '.$nodeclients.' to 0'."\n";
                                  $content->{'nodes'}->[$i]->{'clients'}=0;
                                  $content->{'nodes'}->[$i]->{'clients_other'}=0;
                                }
                        }


                }

                ## debug content after processing

                 # Process array for each of nodecounter-max nodes:
                for (my $i = 0; $i < $nodecounter_max; $i++){
                        # Nodes value parsing

                        $nodeid =  $content->{'nodes'}->[$i]->{'node_id'};
                        $nodeclients = $content->{'nodes'}->[$i]->{'clients'};

                        print $nodeid.':'.$nodeclients."\n";

                }
        ## End Inner Loop
             ## output json should start with version and timestamp:
             ## {"version":2,"timestamp":"2021-06-19T10:20:01+0200",

             ## output json array to file
             $jsontext = encode_json($content);
                ## output json should contain version and timestamp:
                ## {"version":2,"timestamp":"2021-06-19T10:20:01+0200",
                print "\n";
                # print $jsontext;

                print $nl $jsontext;

                close ($nl);

                ## Lets move new file to old source
                move ($destfilename, $filename) or die "The move operation failed: $!";

                }

## End MAIN Loop

} else {
                        print "ERROR: file ".$filename." does not exist.\n";
}


exit 0;


