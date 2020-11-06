package ChoresCal::ConfigReader;

use strict;
use warnings;


sub Read {
    my %Params = @_;
    my $ConfigPath = $Params{Path};
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
                LastDoneDate => $LineValues[1],
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

1;
