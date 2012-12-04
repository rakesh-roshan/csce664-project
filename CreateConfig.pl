#!/usr/bin/perl -w

use strict;
###########################	CONFIGURATION	###############################
my $ConfigFileName = "config";
my $AppConfFileName = "app.conf";
my @SeedSet = ();
for(my $i=11,my $j=0; $j<10; $j++,$i++){
    $SeedSet[$j] = $i;
}

# corresponds to radio range: 40.916
my @Speed             = (0,2,5,7,10,15,20,25,30);
my @PacketArrivalRate = (1, 0.5, 0.25, 0.1, 0.05, 0.025, 0.01, 0.005, 0.0025, 0.001);
my @PauseTime         = (2, 5, 7, 10, 15, 20);
###############################################################################
`rm ./DATA/*`;
`cp glomosim ./DATA/`;
`cp app.conf ./DATA/`;


###############################################################################
#generate all app.conf file needed

for(my $p = 0; $p < @PacketArrivalRate; $p++){

    open (APP_FROM, "$AppConfFileName") || die("Open $AppConfFileName fail!\n");
    print "File $AppConfFileName is opened successfully!\n";
    open (APP_TO, ">./DATA/$AppConfFileName-a$PacketArrivalRate[$p]") || 
	die("Open $AppConfFileName-a$PacketArrivalRate[$p] fail!\n"); 
    my $t = 40 / $PacketArrivalRate[$p];
    print "File $AppConfFileName-a$PacketArrivalRate[$p] is opened successfully!\n";
    
    print APP_TO"CBR		0 	29		","$t		512","	$PacketArrivalRate[$p]", "	125S	166S\n";
    print APP_TO"CBR		3 	20		","$t		512","	$PacketArrivalRate[$p]", "	125S	166S\n";
    print APP_TO"CBR		5 	15		","$t		512","	$PacketArrivalRate[$p]", "	125S	166S\n";
    print APP_TO"CBR		8 	28		","$t		512","	$PacketArrivalRate[$p]", "	125S	166S\n";
    print APP_TO"CBR		9 	10	","$t		512","	$PacketArrivalRate[$p]", "	125S	166S\n";
    		 
    close(APP_FROM);
    close(APP_TO);


    #generate all conf.in file needed
    for(my $sp=0;$sp<@Speed;$sp++){
        my $speed = $Speed[$sp];
        for(my $pa=0;$pa<@PauseTime;$pa++){
            my $pauseTime = $PauseTime[$pa];
            for(my $k=0;$k<@SeedSet;$k++){
                open (CONF_FROM, "$ConfigFileName.in") || 
                    die("Open $ConfigFileName.in fail!\n");
                print "File $ConfigFileName-0.in is opened successfully!\n";
                open (CONF_TO, ">./DATA/$ConfigFileName-sp$speed-p$pauseTime-s$SeedSet[$k]-a$PacketArrivalRate[$p].in") || 
                    die("Open $ConfigFileName-sp$speed-p$pauseTime-s$SeedSet[$k]-a$PacketArrivalRate[$p].in fail!\n"); 
                print "File $ConfigFileName-sp$speed-p$pauseTime-s$SeedSet[$k]-a$PacketArrivalRate[$p].in is opened successfully!\n";
                while(my $line = <CONF_FROM>){
                    if($speed>0){
                        if($line =~ /^ *SEED/){
                            print CONF_TO "SEED  $SeedSet[$k]\n";
                        }elsif($line =~ /^ *MOBILITY-WP-PAUSE/){
                            print CONF_TO "MOBILITY-WP-PAUSE  $pauseTime"."S\n";
                        }elsif($line =~ /^ *MOBILITY-WP-MIN-SPEED/){
                            print CONF_TO "MOBILITY-WP-MIN-SPEED  $speed\n";
                        }elsif($line =~ /^ *MOBILITY-WP-MAX-SPEED/){
                            print CONF_TO "MOBILITY-WP-MAX-SPEED  $speed\n";
                        }elsif($line =~ /^ *APP-CONFIG-FILE/){
                            print CONF_TO "APP-CONFIG-FILE  $AppConfFileName-a$PacketArrivalRate[$p]\n";
                        } else {
                            print CONF_TO "$line";
                        }
                    }else{
                        if($line =~ /^ *SEED/){
                            print CONF_TO "SEED  $SeedSet[$k]\n";
                        }elsif($line =~ /^ *MOBILITY-WP-PAUSE/){
                            print CONF_TO "#MOBILITY-WP-PAUSE  $pauseTime\n";
                        }elsif($line =~ /^ *MOBILITY-WP-MIN-SPEED/){
                            print CONF_TO "#MOBILITY-WP-MIN-SPEED  $speed\n";
                        }elsif($line =~ /^ *MOBILITY-WP-MAX-SPEED/){
                            print CONF_TO "#MOBILITY-WP-MAX-SPEED  $speed\n";
                        }elsif($line =~ /^ *#MOBILITY  NONE/){
                            print CONF_TO "MOBILITY  NONE\n";
                        }elsif($line =~ /^ *MOBILITY *RANDOM-WAYPOINT/){
                            print CONF_TO "#MOBILITY RANDOM-WAYPOINT\n";
                        }elsif($line =~ /^ *APP-CONFIG-FILE/){
                            print CONF_TO "APP-CONFIG-FILE  $AppConfFileName-a$PacketArrivalRate[$p]\n";
                        } else {
                            print CONF_TO "$line";
                        }
                    }
                }
                close(CONF_FROM);
                close(CONF_TO);	
            }
        }
    }
}

###############################################################################
#Generate the simulation file
open(SHELL, ">./DATA/IGF_shell.pl") || die("Create IGF_shell.pl fail!\n");
print	"File IGF_shell.pl is created successfully!\n";

print SHELL "#!/usr/bin/perl -w\n";

for(my $sp=0;$sp<@Speed;$sp++){
    my $speed = $Speed[$sp];
    for(my $pa=0;$pa<@PauseTime;$pa++){
        my $pauseTime = $PauseTime[$pa];
        for(my $k = 0;$k < @SeedSet; $k++){
            for(my $i = 0;$i < @PacketArrivalRate; $i++) {
                print SHELL	"`./glomosim ../$ConfigFileName-sp$speed-p$pauseTime-s$SeedSet[$k]-a$PacketArrivalRate[$i].in`;  \n".
                    "`mv glomo.stat $ConfigFileName-sp$speed-p$pauseTime-s$SeedSet[$k]-a$PacketArrivalRate[$i].stat`;\n";
            }

        }
    }
}

close(SHELL);
`chmod +x ./DATA/IGF_shell.pl`;
