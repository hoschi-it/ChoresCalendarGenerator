#!/bin/env perl
use strict;
use warnings;

use DateTime;
use DateTime::Duration;


use Data::Dumper;

my $CalendarPath = 'calendar.csv';
my $ToDoChar = 'O';


sub ParseConfig {
  my $ConfigPath = 'tasks.conf.csv';
  my @Config = ();

  open(my $ConfigFile, '<', $ConfigPath)
   or die "Error! $!";

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
    else {
      $WasFirstLineRead = 1;
    }
  }    
  close($ConfigFile);

  return @Config;
}


sub WriteCalendar {
  my @Tasks = @_;
  my $CalendarPath = 'calendar.csv';
  my $ToDoChar = 'O';
  my $DaysToPrint = 30;

  # Overwrite previously existing file
  open(my $CalendarFile, '>', $CalendarPath);
  print $CalendarFile " ";
  close($CalendarFile);
  
  open($CalendarFile, '>>', $CalendarPath);
 
  # Write Headers
  foreach my $Task (@Tasks) {
    print $CalendarFile $Task->{Name} . ';';
  }
  print $CalendarFile "\n";

  # Generate Sequences of doing and not-doing
  foreach my $Task (@Tasks) {
    my @Sequence = ();
    my $DaysSinceLastDone = $Task->{Period} - $Task->{Offset};

    foreach (1 .. $DaysToPrint) {
      $DaysSinceLastDone %= $Task->{Period};
      my $IsDueToday = $DaysSinceLastDone == 0;
      my $TodaysSymbol = $IsDueToday? $ToDoChar : ""; 
      push @Sequence, $TodaysSymbol;
      $DaysSinceLastDone++;
    }
  }

  
  my $Today = DateTime->today(
    locale => 'de-DE',
  );
  $Today->set_time_zone( 'Europe/Berlin' );

  # Write the row for each day
  for (my $DayNum = 1; $DayNum <= $DaysToPrint; $DayNum++) {
    
    # Write the date
    my $Date = $Today + DateTime::Duration->new( days => $DayNum -1);
    print $Date->day_of_year == 1 ? $Date->year . ";" : ";" ;
    print $Date->day_of_month == 1 ? $Date->month_abbr . ";" : ";";
    print $Date->day_of_month . ";";
    print $Date->day_abbr . ";";


    # Write the task todo items 
    foreach my $Task (@Tasks){
      
    }

    print "\n";
    
  }

  close($CalendarFile);
}

my @Chores = ParseConfig();

# print "#A: " . Dumper(@Chores);

WriteCalendar(@Chores);

