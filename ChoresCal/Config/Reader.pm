package ChoresCal::Config::Reader;

use strict;
use warnings;

use lib '../..';
require ChoresCal::Utils;


sub Read {
    my %Params = @_;
    ChoresCal::Utils::RequireParams(
        Params => \%Params,
        Required => [ qw( Path ) ],
    );

    my $ConfigPath = $Params{Path};
    my @Config = ();

    open(my $ConfigFile, '<', $ConfigPath)
     or die "Error! $!";

    my $WasFirstLineRead = 0;

    while(<$ConfigFile>) {
        my $Line = $_;
        
        if( $WasFirstLineRead && not _IsLineEmpty($Line) ) {
            my $LineConfig = ConstructHash($Line);
            push @Config, $LineConfig ;
        } 
        else {
            $WasFirstLineRead = 1;
        }
        
    }        
    close($ConfigFile);

    return @Config;
}

sub _IsLineEmpty {
   my $Line = $_[0];
   return $Line =~ m/^[\s]*$/;
}

sub ConstructHash {
    my $Line = $_[0];
    my @Values = split /;/, $Line; 
    my $LineConfig = {
        Period => $Values[0],
        LastDoneDate => $Values[1],
        Name => $Values[2],
    };
    # remove the trailing newline
    $LineConfig->{Name} =~ s/[\r\n]{1}//g;
    return $LineConfig;
}



1;
