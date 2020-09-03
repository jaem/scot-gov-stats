#!/opt/local/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Text::CSV::Hashify;

my %files;
my $debug = 0;
my $outfile = "gov.stats.result.csv";

# $files{datazone}= "orig/stats.Datazone2011Lookup.csv";
# $files{geog}    = "orig/stats.geog.code.register.nt";
$files{codes}   = "./orig/stats.CouncilArea_codes_and_names.csv";
$files{pop}     = "./orig/stats.population-estimates-current-geographic-boundaries.csv";

# $files{cod}     = "orig/stats_causeofdeath.csv";
# $files{testing} = "stats.scot.covid.testing.csv";
$files{cod}     = "scot.covid.deaths.csv";
$files{testing} = "scot.covid.testing.csv";

## ----------------------------------------------------------------------------
## Get data structures
## ----------------------------------------------------------------------------
my $stats_councilCode  = get_data_file_as_hash_ref($debug, 'hoh', 'CouncilArea_code', $files{codes});
my $stats_popEstimate  = get_data_file_as_hash_ref($debug, 'hoh', 'refArea'         , $files{pop});
my $stats_causeOfDeath = get_data_file_as_hash_ref($debug, 'aoh', 'id'              , $files{cod});

my $hash_ref = $stats_causeOfDeath->all; # get a hash of all these values
my $totalDeaths = 0;
my $totalPopulation = 0;
my %results;
my %records;

foreach my $entry (keys ($hash_ref)) {
	# # deep debug
	# print ($entry . "\n");
	# print (Dumper($hash_ref->[$entry]));

   if (! exists $records{$hash_ref->[$entry]{DateCode}}) {
      $records{$hash_ref->[$entry]{DateCode}}=1;
   } else {
      $records{$hash_ref->[$entry]{DateCode}}+=1;
   }

   # crude breakout of the regions
   if ( 
   	    ($hash_ref->[$entry]{FeatureCode} =~ "^S1200") & 
   	    ($hash_ref->[$entry]{DateCode} eq "2020") & 
   	    ($hash_ref->[$entry]{'LocationOfDeath'} eq "All") & 
   	    ($hash_ref->[$entry]{'CauseOfDeath'}    eq "COVID-19 related")
      ) {

      ## more readable reference
      my $c_ref = $stats_councilCode->record($hash_ref->[$entry]{FeatureCode});
      my $p_ref = $stats_popEstimate->record($hash_ref->[$entry]{FeatureCode});
      
      # reference shortcut for readability
      my $key = $hash_ref->[$entry]{FeatureCode};

      if (exists $results{$key}) {
      	print("Warning : Key $key already exists!\n");
      }

      ## Create a results HASH
      $results{$key}{population}   = $p_ref->{Count};
      $results{$key}{region_name}  = $p_ref->{"Reference Area"};
      $results{$key}{covid_deaths} = $hash_ref->[$entry]{Value};
      $results{$key}{covid_deaths_per_100k} = sprintf ("%.2f", ($hash_ref->[$entry]{Value}/( $p_ref->{Count} / 100000 )));
    
   	$totalDeaths += $hash_ref->[$entry]{Value};
      $totalPopulation += $p_ref->{Count};

   }
}

print (Dumper(\%results)) if ($debug);

print("The following DateCodes are in this dataset, with record count:\n");
foreach my $dKey (sort {$a cmp $b} keys (%records)) {
   print ("$dKey : $records{$dKey}\n");
}
print("\n\n");

## Build the CSV structure summary that we want
my $outStr = "FeatureCode,Population,Region,CovidDeaths,CovidDeathsPer100k,\n";
foreach my $sKey (sort {$a cmp $b} keys (%results)) {
   $outStr .= "$sKey,";
   $outStr .= "$results{$sKey}{population},";
   $outStr .= "$results{$sKey}{region_name},";
   $outStr .= "$results{$sKey}{covid_deaths},";
   $outStr .= "$results{$sKey}{covid_deaths_per_100k},";
   $outStr .= "\n";
}
print ("$outStr");

open(FH, '>', $outfile) or die $!;
print FH $outStr;
close(FH);

print ("Deaths          : $totalDeaths\n");
print ("TotalPopulation : $totalPopulation\n");
print ("DeathsPer1Mil   : " . ($totalDeaths/($totalPopulation/1000000)) . "\n");

## ----------------------------------------------------------------------------
## break this call into a sub, so we can add some common debug printing.
## ----------------------------------------------------------------------------
sub get_data_file_as_hash_ref {
   my $debug    = shift;
   my $type     = shift; ## hoh or aoh(used when there is no unique key)
   my $colName  = shift;
   my $dataFile = shift;
   print ("Processing $dataFile\n");
   my $obj = Text::CSV::Hashify->new( {file => $dataFile, format => $type, key => $colName } );
   print(Dumper($obj)) if ($debug);
   print(Dumper($obj->keys)) if ($debug & ($type eq 'hoh'));
   return $obj;
}
