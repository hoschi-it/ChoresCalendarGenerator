package ChoresCal::Writer;

use strict;
use warnings;


sub Write {
    my @Tasks = @_;
    
}

sub _OpenEmptyFileHandle {
    my $CalendarPath = shift;

    # Overwrite previously existing file
    open(my $CalendarFile, '>', $CalendarPath);
    print $CalendarFile " ";
    close($CalendarFile);
    
    open($CalendarFile, '>>', $CalendarPath);

    return $CalendarFile;
}

sub _WriteHeaders {
    my %Params = @_;
    print $Params{File} ';;;;';
    
    foreach my $Task (@{$Params{Tasks}}) {
        print $Params{File} $Task->{Name} . ';';
    }
    print $Params{File};
}

sub _WriteTasks

1;
