#!/bin/env perl

package ChoresCal;

use strict;
use warnings;

use Cwd qw(cwd);

use lib '.';

require ChoresCal::Date;
require ChoresCal::Config::Reader;
require ChoresCal::Config::Parser;
require ChoresCal::Writer;


my $CalendarPath = cwd() . '/calendar.csv';
my $ConfigPath   = cwd() . '/tasks.conf.csv';
my $ToDoChar     = 'O';
my $DaysToPrint = 30;


my @Chores = ChoresCal::Config::Reader::Read(
    Path => $ConfigPath,
);

@Chores = ChoresCal::Config::Parser::Parse(
    @Chores
);

ChoresCal::Writer::Write(
    File      => $CalendarPath,
    Tasks     => [@Chores],
    ToDoChar  => $ToDoChar,
    DaysCount => $DaysToPrint,
);


