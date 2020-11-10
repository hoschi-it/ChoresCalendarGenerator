package ChoresCal::Writer;

use strict;
use warnings;

require DateTime;
require DateTime::Duration;

use Test::More;
use Params::Check qw{check};

use lib '..';
require ChoresCal::Utils;


sub Write {
    my %Params = @_;

    ChoresCal::Utils::RequireParams(
        Params => \%Params,
        Required => [ qw(File Tasks ToDoChar DaysCount ) ],
    );
    my @Tasks = @{$Params{Tasks}};
    {
        my $ExistsTasks = defined (scalar @Tasks);
        my $FirstTask = $Tasks[0];
        my $ExistsTaskSequence = exists($FirstTask->{Sequence});
        #  ok $ExistsTasks && $ExistsTaskSequence, ParamTestMsg('sequence of the first task');
    }

    my $FileHandle = _OpenEmptyFileHandle(
        FilePath => $Params{File}
    );

    _WriteHeaders(
        FileHandle => $FileHandle,
        Tasks      => $Params{Tasks},
    );

    _WriteTasks(
        DaysCount  => $Params{DaysCount},
        FileHandle => $FileHandle,
        Tasks      => [@Tasks],
        ToDoChar   => $Params{ToDoChar},
    );
    close($CalendarFile);
}


sub _OpenEmptyFileHandle {
    my %Params = @_;
    ChoresCal::Utils::RequireParams(
        Params   => \%Params,
        Required => [ qw(FilePath)  ],
    );

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
    ChoresCal::Utils::RequireParams(
        Params   => \%Params,
        Required => [ qw(FileHandle Tasks)  ],
    );

    my $File = $Params{FileHandle};

    print $File ';;;;';
    
    foreach my $Task (@{$Params{Tasks}}) {
        print $File $Task->{Name} . ';';
    }
    print $File "\n";
}


sub _GetDateStr {
    my %Params= @_;
    ChoresCal::Utils::RequireParams(
        Params   => \%Params,
        Required => [ qw(IsFirst Date)  ],
    );
   
    my $IsYearToBeWritten  = ($Params{Date}->day_of_year  == 1) || $Params{IsFirst};
    my $IsMonthToBeWritten = ($Params{Date}->day_of_month == 1) || $Params{IsFirst};

    my $CsvDate = "";
    $CsvDate .= $IsYearToBeWritten ? $Params{Date}->year . ";" : ";" ;
    $CsvDate .= $IsMonthToBeWritten ? $Params{Date}->month_abbr . ";" : ";";
    $CsvDate .= $Params{Date}->day_of_month . ";";
    $CsvDate .= $Params{Date}->day_abbr . ";";
    return $CsvDate;
}


sub _WriteTasks {
    my %Params = @_;
    ChoresCal::Utils::RequireParams(
        Params   => \%Params,
        Required => [ qw(DaysCount FileHandle Tasks ToDoChar)  ],
    );

    my $CalendarFile = $Params{FileHandle};
    my $Today = DateTime->today(
        locale => 'de-DE',
    );
    $Today->set_time_zone( 'Europe/Berlin' );

    # Write the row for each day
    my $DayNum;
    for ($DayNum = 1; $DayNum <= $Params{DaysCount}; $DayNum++) {
        
        # Write the date
        my $Date = $Today + DateTime::Duration->new( days => $DayNum -1);
        my $DateStr = _GetDateStr(
            IsFirst => $DayNum == 1,
            Date    => $Date,
        );
        print $CalendarFile $DateStr;

        # Write the task todo items 
        foreach my $Task (@{$Params{Tasks}}){
            my $Text = "";
            if($Task->{Sequence}[$DayNum -1]) {
                $Text .= $Params{ToDoChar};
            }
            $Text .= ";";
            print $CalendarFile $Text;
        }
        print $CalendarFile "\n";
    }
}


1;
