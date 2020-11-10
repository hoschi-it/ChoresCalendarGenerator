package ChoresCal::Writer;

use strict;
use warnings;

use Test::More;


sub ParamCheckMessage {
    my $Description       = $_[0];
    my $ParamCheckMessage = 'The %s should be given.';
    my $Sentence = sprintf($ParamCheckMessage, $Description);
    return $Sentence;
}

sub Write {
    my %Params = @_;
    ok exists($Params{File}),      ParamCheckMessage('filepath');
    ok exists($Params{Tasks}),     ParamCheckMessage('tasks');
    ok exists($Params{ToDoChar}),  ParamCheckMessage('character to mark a to do item');
    ok exists($Params{DaysCount}), ParamCheckMessage('number of days to print');

    my $FileHandle = _OpenEmptyFileHandle(
        FilePath => $Params{File}
    );

    _WriteHeaders(
        FileHandle => $FileHandle,
        Tasks      => $Params{Tasks},
    );

    _GenerateTasksSequences(
        Tasks     => $Params{Tasks},
        DaysCount => $Params{DaysCount},
        ToDoChar  => $Params{ToDoChar},
    );
    
    {
        my $ExistsTaskSequence = exists($Params{Tasks}) and 
                                 exists($Params{Tasks}[0]{Sequence});
        ok $ExistsTaskSequence, ParamCheckMessage('sequence of the first task');
    }

    #_OldWayToDoIt();

}

sub _OpenEmptyFileHandle {
    # needs to contain File
    my %Params = @_;
    ok exists($Params{FilePath}), ParamCheckMessage('filepath');

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
    ok exists($Params{FileHandle}), ParamCheckMessage('file handle');
    ok exists($Params{Tasks}),      ParamCheckMessage('tasks configuration');

    my $File = $Params{FileHandle};

    print $File ';;;;';
    
    foreach my $Task (@{$Params{Tasks}}) {
        print $File $Task->{Name} . ';';
    }
    print $File "\n";
 }

sub _WriteTasks {
}

sub _GenerateTasksSequences {
    my %Params = @_;
    ok exists($Params{Tasks}),     ParamCheckMessage('tasks configuration');
    ok exists($Params{DaysCount}), ParamCheckMessage('number of days to print');
    ok exists($Params{ToDoChar}),  ParamCheckMessage('character to represent ToDo items');

    # Generate Sequences of doing and not-doing
    foreach my $Task (@{$Params{Tasks}}) {
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
}


# sub _OldWayToDoIt {
# 
#     my $Today = DateTime->today(
#         locale => 'de-DE',
#     );
#     $Today->set_time_zone( 'Europe/Berlin' );
# 
#     # Write the row for each day
#     my $DayNum;
#     for ($DayNum = 1; $DayNum <= $DaysToPrint; $DayNum++) {
#         
#         # Write the date
#         my $Date = $Today + DateTime::Duration->new( days => $DayNum -1);
#         my $IsYearToBeWritten = ($Date->day_of_year == 1)   
#                                 ||   ($DayNum == 1);
#         my $IsMonthToBeWritten = ($Date->day_of_month == 1) 
#                                  || ($DayNum == 1);
# 
#         print $CalendarFile $IsYearToBeWritten ? 
#             $Date->year . ";" : ";" ;
#         print $CalendarFile $IsMonthToBeWritten ?
#             $Date->month_abbr . ";" : ";";
#         print $CalendarFile $Date->day_of_month . ";";
#         print $CalendarFile $Date->day_abbr . ";";
# 
# 
#         # Write the task todo items 
#         foreach my $Task (@Tasks){
#              print $CalendarFile $Task->{Sequence}[$DayNum -1] . ";"; 
#         }
#         print $CalendarFile "\n";
#     }
#     close($CalendarFile);
# }

1;
