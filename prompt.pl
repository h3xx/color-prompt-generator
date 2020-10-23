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
require Color::Transform;
require Prompt;

MAIN: {

    # \e)0 sets G1 to special characters,
    # \x0e (\016) puts terminal into G1 mode,
    # \x0f (\017) puts terminal into normal mode

    my $git = 1;
    my $utf8 = 0;

    my ($host_color, $user_color);
    if ($ENV{USER} eq 'root') {
        $host_color = Color->new(
            fg => 39, # blue-teal
            bold => 0,
        );
        $user_color = Color->new(
            fg => 45, # teal
            bold => 1,
        );
    } else {
        $host_color = Color->new(
            fg => 141, # purple
            bold => 0,
        );
        $user_color = Color->new(
            fg => 207, # hot magenta
            bold => 1,
        ),
    }

    my $prompt = Prompt->new(
        utf8 => $utf8,
        git => $git,
        host_color => $host_color,
        user_color => $user_color,
    );

    binmode(STDOUT, ":utf8");
    print $prompt, "\n";
}
