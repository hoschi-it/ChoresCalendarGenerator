package ChoresCal::Writer;

use strict;
use warnings;

use Test::More;


sub ParamTestMsg {
    my $Description       = $_[0];
    my $ParamTestMsg = 'The %s should be given.';
    my $Sentence = sprintf($ParamTestMsg, $Description);
    return $Sentence;
}

sub Write {
    my %Params = @_;
    ok exists($Params{File}),      ParamTestMsg('filepath');
    ok exists($Params{Tasks}),     ParamTestMsg('tasks');
    ok exists($Params{ToDoChar}),  ParamTestMsg('character to mark a to do item');
    ok exists($Params{DaysCount}), ParamTestMsg('number of days to print');

    my $FileHandle = _OpenEmptyFileHandle(
        FilePath => $Params{File}
    );

    _WriteHeaders(
        FileHandle => $FileHandle,
        Tasks      => $Params{Tasks},
    );

    my @Tasks = _GenerateTasksSequences(
        Tasks     => $Params{Tasks},
        DaysCount => $Params{DaysCount},
        ToDoChar  => $Params{ToDoChar},
    );
    
    {
        my $ExistsTasks = defined (scalar @Tasks);
        my $FirstTask = $Tasks[0];
        my $ExistsTaskSequence = exists($FirstTask->{Sequence});
        ok $ExistsTasks && $ExistsTaskSequence, ParamTestMsg('sequence of the first task');
    }

    _WriteTasks(
        DaysCount  => $Params{DaysCount},
        FileHandle => $FileHandle,
        Tasks      => [@Tasks],
    );

    #_OldWayToDoIt();

}

sub _OpenEmptyFileHandle {
    # needs to contain File
    my %Params = @_;
    ok exists($Params{FilePath}), ParamTestMsg('filepath');

    # Overwrite previously existing file
    open(my $CalendarFile, '>', $Params{FilePath});
    print $CalendarFile " ";
    close($CalendarFile);
   
    # Create filehandle for writing calendar
    open($CalendarFile, '>>', $Params{FilePath});
    return $CalendarFile;
}

sub _WriteHeaders {
    my %Params = @_;
    ok exists($Params{FileHandle}), ParamTestMsg('file handle');
    ok exists($Params{Tasks}),      ParamTestMsg('tasks configuration');

    my $File = $Params{FileHandle};

    print $File ';;;;';
    
    foreach my $Task (@{$Params{Tasks}}) {
        print $File $Task->{Name} . ';';
    }
    print $File "\n";
}


sub _GenerateTasksSequences {
    my %Params = @_;
    ok exists($Params{Tasks}),     ParamTestMsg('tasks configuration');
    ok exists($Params{DaysCount}), ParamTestMsg('number of days to print');
    ok exists($Params{ToDoChar}),  ParamTestMsg('character to represent ToDo items');

    my @Tasks = @{$Params{Tasks}};
    # Generate Sequences of doing and not-doing
    foreach my $Task (@Tasks) {
        my @Sequence = ();
        my $DaysSinceLastDone = $Task->{Period} - $Task->{Offset};

        foreach (1 .. $Params{DaysCount}) {
            $DaysSinceLastDone %= $Task->{Period};
            my $IsDueToday = $DaysSinceLastDone == 0;
            my $TodaysSymbol = $IsDueToday? $Params{ToDoChar} : ""; 
            push @Sequence, $TodaysSymbol;
            $DaysSinceLastDone++;
        }
        $Task->{Sequence} = [@Sequence];
    }

    return @Tasks;
}


sub _WriteTasks {
    my %Params = @_;
    ok exists($Params{DaysCount}),  ParamTestMsg('number of days to print');
    ok exists($Params{FileHandle}), ParamTestMsg('calendar file handle'); 
    ok exists($Params{Tasks}),      ParamTestMsg('task configuration');

    my $Today = DateTime->today(
        locale => 'de-DE',
    );
    $Today->set_time_zone( 'Europe/Berlin' );

    my $CalendarFile = $Params{FileHandle};

    # Write the row for each day
    my $DayNum;
    for ($DayNum = 1; $DayNum <= $Params{DaysCount}; $DayNum++) {
        
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
        foreach my $Task (@{$Params{Tasks}}){
            my $Char = $Task->{Sequence}[$DayNum -1] . ";";
            print $CalendarFile $Char;
        }
        print $CalendarFile "\n";
    }
    close($CalendarFile);
}


1;
