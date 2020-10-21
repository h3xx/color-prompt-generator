#!/usr/bin/perl
# vi: et sts=4 sw=4 ts=4
use strict;
use warnings;
use Getopt::Std	    qw/ getopts /;
use File::Basename  qw/ basename dirname /;
use Cwd             qw/ realpath /;

# (this prepends to the load path)
use lib &dirname(&realpath($0));

require Color;
require Color::Cube;

# Author: Todd Larason <jtl@molehill.org>
# $XFree86: xc/programs/xterm/vttests/256colors2.pl,v 1.2 2002/03/26 01:46:43 dickey Exp $
# modified by Dan Church to output the terminal color numbers in order to aid in writing Vim color schemes
# modified AGAIN by Dan Church to provide better contrast between the colors and the numbers
# modified AGAIN by Dan Church to show a specific palette by passing the script a list of numbers
# modified AGAIN by Dan Church to make OO and DRY


sub HELP_MESSAGE {
    my $fh = shift;
    print $fh <<EOF
Usage: $0 [OPTIONS] [COLOR...]
Display a terminal color cube.

  -a            Display TERM::ANSIColor compatible aliases.
  -O            When filtering by colors, show ONLY those colors.

Copyright (C) 2015-2020 Dan Church.
License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.
EOF
;
    exit 0;
}


MAIN: {
    # 164 (n) -> 196 (b) -> 99 (b) -> 159 (n)
    my @colors = (
        Color->new(
            fg => 164,
            bold => 0,
        ),
        Color->new(
            fg => 196,
            bg => 237,
            bold => 1,
        ),
        Color->new(
            fg => 99,
            bold => 1,
        ),
        Color->new(
            fg => 159,
            bold => 0,
        ),
    );
    my $d = Color->new;

    while (@colors) {
        my $n = shift @colors;
        print $d->transform_to($n), $n->{fg};
        $d = $n;
    }
    print "\n";
    die;


    &getopts('aO', \ my %opts);

    my %reverse_colors;
    my $limit_to_colors;
    if (@ARGV) {
        @reverse_colors{0..255} = (1) x 256;
        if ($opts{O}) {
            $limit_to_colors = {};
            @{$limit_to_colors}{@ARGV} = (1) x @ARGV;
        } else {
            @reverse_colors{@ARGV} = (0) x @ARGV;
        }
    }

    my $cc = Color::Cube->new(
        reverse_colors => \%reverse_colors,
        limit_to_colors => $limit_to_colors,
        ($opts{a} ? (format => 'ansicolor') : ()),
    );

    print $cc, "\n";
}

1;
