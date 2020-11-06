package ChoresCal::Config::Parser;

use strict;
use warnings;


sub Parse {
    my @Config = @_;

    foreach my $RefConfigEntry (@Config) {
        my $LastDoneDateStr = $RefConfigEntry->{LastDoneDate};
        my $LastDoneDate = ChoresCal::Date::Parse($LastDoneDateStr);

        my $DaysPassedBy = ChoresCal::Date::DaysSince(
            HistoricalDate => $LastDoneDate,
            CurrentDate    => DateTime->now,
        );
        $RefConfigEntry->{Offset} = $DaysPassedBy;
    }

    return @Config;

}

1; 
