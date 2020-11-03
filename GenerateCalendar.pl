#!/bin/env perl
use strict;
use warnings;
use Data::Dumper;

my $CalendarPath = 'calendar.csv';


sub ParseConfig {
  my $ConfigPath = 'tasks.conf.csv';
  my @Config = ();

  open(my $ConfigFile, '<', $ConfigPath)
    or die "Couldn't open file $ConfigPath, $!";

  my $WasFirstLineRead = 0;

  while(<$ConfigFile>) {
    my $Line = $_;
    my $IsLineEmpty = $Line =~ m/^[\s]*$/;
    
    if( $WasFirstLineRead && not $IsLineEmpty ) {
      my @LineValues = split /;/, $Line;
      
      my $LineConfig = {
        Period => $LineValues[0],
        Offset => $LineValues[1],
        Name => $LineValues[2],
      };
      # remove the trailing newline
      $LineConfig->{Name} =~ s/[\r\n]{1}//g;
      
      push @Config, $LineConfig ;
    }
    $WasFirstLineRead = 1;
  }
  close($ConfigFile);

  return @Config;
}

my @Config = ParseConfig();
print Dumper(@Config);

