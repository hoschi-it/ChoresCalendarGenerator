package ChoresCal::Scheduler;

use strict;
use warnings;

use Test::More;

use lib '..';
require ChoresCal::Utils;

sub GenerateTasksSequences {
    my %Params = @_;

    ChoresCal::Utils::RequireParams(
        Params   => \%Params,
        Required => [ qw(Tasks DaysCount) ],
    );

    my @Tasks = @{$Params{Tasks}};
    # Generate Sequences of doing and not-doing
    foreach my $Task (@Tasks) {
        my @Sequence = ();
        my $DaysSinceLastDone = $Task->{Period} - $Task->{Offset};

        foreach (1 .. $Params{DaysCount}) {
            $DaysSinceLastDone %= $Task->{Period};
            my $IsDueToday = $DaysSinceLastDone == 0;
            my $TodaysSymbol = $IsDueToday; 
            push @Sequence, $TodaysSymbol;
            $DaysSinceLastDone++;
        }
        $Task->{Sequence} = [@Sequence];
    }

    return @Tasks;
}

1;
