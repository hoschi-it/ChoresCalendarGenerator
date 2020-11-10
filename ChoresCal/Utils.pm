package ChoresCal::Utils;

use strict;
use warnings;


sub RequireParams {
    use Params::Check qw{check};
    
    $Params::Check::PRESERVE_CASE = 1;
    my $IsVerbose = 1;

    my %Params = @_;
    my %Checkable = %{$Params{Params}};
    my @Required  = @{$Params{Required}};
    
    my %CheckRequired = ();
    foreach my $Name (@Required) {
        my %Entry = (
            required => 1,
            defined  => 1,
           ,
        );
        $CheckRequired{$Name} = \%Entry;
    }

    my $Parse = check(
        \%CheckRequired,
        \%Checkable,
        $IsVerbose,
    );
}

1;
