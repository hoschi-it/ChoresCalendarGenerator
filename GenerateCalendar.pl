#!/bin/env perl

package ChoresCal;

use strict;
use warnings;

use Cwd qw(cwd);

use lib '.';

require ChoresCal::Date;
require ChoresCal::Config::Reader;
require ChoresCal::Config::Parser;
require ChoresCal::Writer;

# TODO purge it?
use Date::Parse;
use DateTime;
use DateTime::Duration;


my $CalendarPath = cwd() . 'calendar.csv';
my $ConfigPath   = cwd() . '/tasks.conf.csv';
my $ToDoChar     = 'O';
my $DaysToPrint = 30;
my $CalendarPath = 'calendar.csv';


sub ParseConfig {
    my @Config = ChoresCal::Config::Reader::Read(
        Path => $ConfigPath,
    );
    @Config = ChoresCal::Config::Parser::Parse(
        @Config
    );
    return @Config;
}


sub WriteCalendar {
    my @Tasks = @_;

    # Overwrite previously existing file
    open(my $CalendarFile, '>', $CalendarPath);
    print $CalendarFile " ";
    close($CalendarFile);
    
    open($CalendarFile, '>>', $CalendarPath);

    # Write Headers
    print $CalendarFile ';;;;';
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
        $Task->{Sequence} = [@Sequence];
    }

    
    my $Today = DateTime->today(
        locale => 'de-DE',
    );
    $Today->set_time_zone( 'Europe/Berlin' );

    # Write the row for each day
    for (my $DayNum = 1; $DayNum <= $DaysToPrint; $DayNum++) {
        
        # Write the date
        my $Date = $Today + DateTime::Duration->new( days => $DayNum -1);
        my $IsYearToBeWritten = ($Date->day_of_year == 1)   
                                ||   ($DayNum == 1);
        my $IsMonthToBeWritten = ($Date->day_of_month == 1) 
                                 || ($DayNum == 1);

        print $CalendarFile $IsYearToBeWritten ? 
            $Date->year . ";" : ";" ;
        print $CalendarFile $IsMonthToBeWritten ?
            $Date->month_abbr . ";" : ";";
        print $CalendarFile $Date->day_of_month . ";";
        print $CalendarFile $Date->day_abbr . ";";


        # Write the task todo items 
        foreach my $Task (@Tasks){
             print $CalendarFile $Task->{Sequence}[$DayNum -1] . ";"; 
        }
        print $CalendarFile "\n";
    }
    close($CalendarFile);
}

my @Chores = ParseConfig();
WriteCalendar(@Chores);

