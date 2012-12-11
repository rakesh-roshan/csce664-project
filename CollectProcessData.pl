#!/usr/bin/perl -w

use strict;
###############	CONFIGURATION	############################################
my $ConfigFileName = "config";
my @SeedSet = ();

for(my $i=11,my $j=0; $j<10; $j++,$i++){
    $SeedSet[$j] = $i;
}

# corresponds to radio range: 40.916
#my @Speed             = (0,2,5,7,10,15,20,25,30);
#my @PacketArrivalRate = (1, 0.5, 0.25, 0.1, 0.05, 0.025, 0.01, 0.005, 0.0025, 0.001);
#my @PauseTime         = (2, 5, 7, 10, 15, 20);
my @Speed             = (0,2,5,7,10,15,20,25,30);
my @PacketArrivalRate = (0.5);
my @PauseTime         = (2, 5, 7, 10, 15, 20);


######## some parameters for confidence intervals ##########################

#$CtkVal  = 6.314;	### t(90%,n-1=1)  use T distribution
#$SamSize = 2;		### n=2

#$CtkVal  = 2.132;	### t(90%,n-1=4)  use T distribution
#$SamSize = 5;		### n=5

#$CtkVal  = 1.729;	### t(90%,n-1=19)  use T distribution
#$SamSize = 20;		### n=20

#$CtkVal  = 1.660;	### t(90%,n-1=99)
#$SamSize = 100;		### n=100


###############################################################################
############################# for # Successfully Delivered Packets #####################
###############################################################################
for(my $i=0;$i<@PacketArrivalRate;$i++){
    open(DLV_FILE,">$ConfigFileName-SuccDeliPkt_$PacketArrivalRate[$i].EXCEL") ||
	die("Create $ConfigFileName-SuccDeliPkt_$PacketArrivalRate[$i].EXCEL fail!\n");
    print	"File $ConfigFileName-SuccDeliPkt_$PacketArrivalRate[$i].EXCEL is opened successfully!\n";
    open(DELAY_FILE,">$ConfigFileName-AvgDelay_$PacketArrivalRate[$i].EXCEL") ||
	die("Create $ConfigFileName-AvgDelay_$PacketArrivalRate[$i].EXCEL fail!\n");
    print	"File $ConfigFileName-AvgDelay_$PacketArrivalRate[$i].EXCEL is opened successfully!\n";
    open(THROUGHPUT_FILE,">$ConfigFileName-Throughput_$PacketArrivalRate[$i].EXCEL") ||
	die("Create $ConfigFileName-Throughput_$PacketArrivalRate[$i].EXCEL fail!\n");
    print	"File $ConfigFileName-Throughput_$PacketArrivalRate[$i].EXCEL is opened successfully!\n";
    
    print DLV_FILE "TitleText: Average Packet Delivery Rate with Speed.\n".
        "XUnitText: Speed(in m/sec)\n".
        "YUnitText: Packet Delivery Rate\n";
    print DELAY_FILE "TitleText: Average Packet Delay with Speed.\n".
        "XUnitText: Speed(in m/sec)\n".
        "YUnitText: Packet Delay(s)\n";
    print THROUGHPUT_FILE "TitleText: Average Packet Throughput with Speed.\n".
        "XUnitText: Speed(in m/sec)\n".
        "YUnitText: Packet Throughput(bits per sec)\n";
    for(my $pa=0;$pa<@PauseTime;$pa++){
        my $pauseTime = $PauseTime[$pa];
        
        print DLV_FILE "\"Pause Time $pauseTime\"\n";
        print DELAY_FILE "\"Pause Time $pauseTime\"\n";
        print THROUGHPUT_FILE "\"Pause Time $pauseTime\"\n";
        for(my $sp=0;$sp<@Speed;$sp++){
            my $speed = $Speed[$sp];
            print	DLV_FILE	"$speed ";
            print	DELAY_FILE	"$speed ";
            print	THROUGHPUT_FILE	"$speed ";
	
            my $Throughput = 0;
            my $Delay = 0;
            my $DlvRate = 0;
            for(my $j=0;$j<@SeedSet;$j++){	
                open(GLOMO_STAT, "<./$ConfigFileName-sp$speed-p$pauseTime-s$SeedSet[$j]".
                     "-a$PacketArrivalRate[$i].stat") 
                    || die("Open ./$ConfigFileName-sp$speed-p$pauseTime-s$SeedSet[$j]".
                           "-a$PacketArrivalRate[$i].stat fail!\n");
	    	
                #print	"File ./$ConfigFileName-sp$speed-p$pauseTime-s$SeedSet[$j]".
                #    "-a$PacketArrivalRate[$i].stat is opened successfully!\n";	
	    
                my $SuccDeliPkt = 0;
                my $PktSent = 0;
                while(my $line = <GLOMO_STAT>){
                    if($line =~ /Total number of packets received:/){
                        my @array = split(/:/,$line);
                        $SuccDeliPkt += $array[@array-1];
                        #print "Rcvd $array[@array-1]\n";
                    }elsif($line =~ /Total number of packets sent:/){
                        my @array = split(/:/,$line);
                        $PktSent += $array[@array-1];                        
                        #print "Sent $array[@array-1]\n";
                    }elsif($line =~ /AppCbrServer,.*Throughput .bits per second.:/i){
                        
                        my @array = split(/:/,$line);
                        $Throughput += $array[@array-1];
                        #print "Throughput $array[@array-1]\n";
                    }elsif($line =~ /Average end-to-end delay/){
                        my @array = split(/:/,$line);
                        $Delay += $array[@array-1];
                        #print "Delay $array[@array-1]\n";
                    }
                }
                $DlvRate += ($SuccDeliPkt/$PktSent); 
                close(GLOMO_STAT);
            
            }
            my $avgDlvRate = $DlvRate/@SeedSet;
            my $avgDelay = $Delay/@SeedSet;
            my $avgThroughput = $Throughput/@SeedSet;
            print	DLV_FILE	" $avgDlvRate \n";
            print	DELAY_FILE	" $avgDelay \n";
            print	THROUGHPUT_FILE	" $avgThroughput \n";
        }
        print	DLV_FILE	" \n\n";
        print	DELAY_FILE	"  \n\n";
        print	THROUGHPUT_FILE	"  \n\n";
    }
    close(DLV_FILE);
    close(DELAY_FILE);
    close(THROUGHPUT_FILE);
}

