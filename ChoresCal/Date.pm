package ChoresCal::Date;

use strict;
use warnings;

use Date::Parse;
use DateTime;
use DateTime::Duration;

use lib '..';
require ChoresCal::Utils;

sub Parse {
    my $DateString = $_[0];
    $_ = $DateString =~ /(?<day>[0-3]?[0-9]{1})\.(?<month>[0-1]?[0-9]{1})\.(?<year>[0-9]{1,4})/;
    my ($Day, $Month, $Year) = ($1, $2, $3);
    return DateTime->new(
        year => $Year,
        month => $Month,
        day => $Day,
    );
}

sub DaysSince {
    my %Params = @_;
    ChoresCal::Utils::RequireParams(
        Params => \%Params,
        Required => [ qw( HistoricalDate CurrentDate )],
    );

    my $HistoricalDate = $Params{HistoricalDate};
    my $CurrentDate  = $Params{CurrentDate};

    my $Difference   = $CurrentDate - $HistoricalDate;
    return $Difference->days;
}

1;
