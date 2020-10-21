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

    my @colors;
    my $git = 1;
    my $utf8 = 0;

    if ($ENV{USER} eq 'root') {
        @colors = (
            Color->new(
                fg => 39, # blue-teal
                bold => 0,
            ),
            Color->new(
                fg => 45, # teal
                bold => 1,
            ),
        );
    } else {
        @colors = (
            Color->new(
                fg => 141, # purple
                bold => 0,
            ),
            Color->new(
                fg => 207, # hot magenta
                bold => 1,
            ),
        );
    }

    my $prompt = Prompt->new(
        user_color => $colors[1],
        host_color => $colors[0],
    );

    #print $prompt, "\n";
    (my $p = $prompt) =~ s/'/'\\''/g;
    print "PROMPT_COMMAND='$p'\n";
    #print q~__git_ps1 '\[\e)0\e[1;30m\016\]lqqu\[\017\]\l \[\e[1;38;5;207m\]\u\[\e[0m\]@\[\e[0;38;5;141m\]\h'~;
    #print q~'\[\e[1;30m\016\] tq\`\[\017\]'"$(err=$?; [[ $err -eq 0 ]] || printf ' \[%s\][%d]' '\e[1;38;5;222;48;5;235m' $err)"~;
    #print q~'\n\[\e[0m\e[1;30m\016\]mq[ \[\e[0m\017\]\w\[\e[1;30m\] ]= \[\e[1;37m\]\$\[\e[0m\] ' ' %s' ; history -a~, "\n";

#    my $lc = Color->new;
#
#    foreach my $color (@colors) {
#        print $lc->transform_to($color)->escaped;
#        print "0";
#        $lc = $color;
#    }
#
    #		'\e[0;38;5;141m' '\e[1;38;5;207m' '\e[0;38;5;39m' '\e[1;38;5;45m')
}
