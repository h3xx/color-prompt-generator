#!/usr/bin/perl
# vi: et sts=4 sw=4 ts=4
use strict;
use warnings;
use Getopt::Long qw/ GetOptions /;

# (this prepends to the load path) :squash-ignore-line:
use File::Basename  qw/ dirname /; # :squash-ignore-line:
use Cwd             qw/ realpath /; # :squash-ignore-line:
use lib &dirname(&realpath($0)); # :squash-ignore-line:

require Prompt;

sub HELP_MESSAGE {
    my $fh = shift;
    print $fh <<EOF
Usage: $0 [OPTIONS]

  --git     Generate a git prompt (default).
  --no-git  Generate a non-git prompt.
  --basic-git  Generate a basic git prompt with only the branch name.
  --utf8    Generate a UTF-8 prompt.
  --no-utf8 Generate a non-UTF-8 prompt (default).
  -h, --host-color=COLOR
  -u, --user-color=COLOR
  -f, --frame-color=COLOR   (default 0:b)
  -s, --strudel-color=COLOR (default 7:-0)
  -e, --err-color=COLOR     (default 222:-235:b)

Colors are specified using a colon-separated list:
  "39:-235:b:u" means color 39 (blue-teal) on color 235 (slate),
      +bold +underline

Copyright (C) 2020 Dan Church.
License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.
EOF
;
    exit 0;
}

MAIN: {
    my (
        $basic_git,
        $err_color,
        $frame_color,
        $git,
        $host_color,
        $no_git,
        $no_utf8,
        $strudel_color,
        $user_color,
        $utf8,
    );
    # Defaults
    ($git, $utf8, $basic_git) = (1, 0, 0);

    &GetOptions(
        'utf8' => \$utf8,
        'no-utf8' => \$no_utf8,
        'git' => \$git,
        'no-git' => \$no_git,
        'basic-git' => \$basic_git,
        'user-color=s' => \$user_color, 'u=s' => \$user_color,
        'host-color=s' => \$host_color, 'h=s' => \$host_color,
        'frame-color=s' => \$frame_color, 'f=s' => \$frame_color,
        'strudel-color=s' => \$strudel_color, 's=s' => \$strudel_color,
        'err-color=s' => \$err_color, 'e=s' => \$err_color,
    );
    $git = 0 if defined $no_git;
    $utf8 = 0 if defined $no_utf8;

    if ($ENV{USER} eq 'root') {
        # blue-teal
        $host_color = '39' unless defined $host_color;
        # teal
        $user_color = '45:b' unless defined $user_color;
    } else {
        # purple
        $host_color = '141' unless defined $host_color;
        # hot magenta
        $user_color = '207:b' unless defined $user_color;
    }

    my $prompt = Prompt->new(
        utf8 => $utf8,
        colors => {
            defined $host_color ? (host => $host_color) : (),
            defined $user_color ? (user => $user_color) : (),
            defined $frame_color ? (frame => $frame_color) : (),
            defined $strudel_color ? (strudel => $strudel_color) : (),
            defined $err_color ? (err => $err_color) : (),
        },
        features => {
            git => $git,
        },
        basic_git => $basic_git,
    );

    binmode(STDOUT, ":utf8");
    print $prompt, "\n";
}
