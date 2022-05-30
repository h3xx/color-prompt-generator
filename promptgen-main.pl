#!/usr/bin/perl
# vi: et sts=4 sw=4 ts=4
use strict;
use warnings;

=head1 NAME

promptgen.pl - Color prompt generator

=head1 SYNOPSIS

B<promptgen.pl> [I<OPTION>]...

=head1 OPTIONS

Colors are specified using a colon-separated list in the form of I<FG:BG:FLAG...>

C<39:-235:b:u> means color 39 (blue-teal) on color 235 (slate), +bold +underline

=over 4

=item B<--git>

Generate a git prompt (default).

=item B<--no-git>

Generate a non-git prompt.

=item B<--basic-git>

Generate a basic git prompt with only the branch name.

=item B<--utf8>

Generate a UTF-8 prompt.

=item B<--no-utf8>

Generate a non-UTF-8 prompt (default).

=item B<-h> I<COLOR>, B<--host-color>=I<COLOR>

=item B<-u> I<COLOR>, B<--user-color>=I<COLOR>

=item B<-f> I<COLOR>, B<--frame-color>=I<COLOR>

Default is C<0:b>.

=item B<-s> I<COLOR>, B<--strudel-color>=I<COLOR>

Set the color of the C<@> character. Default is C<7:-0>.

=item B<-e> I<COLOR>, B<--err-color>=I<COLOR>

Set the color of the error return code message. Default is C<222:-235:b>.

=item B<--help>

Display this help and exit.

=back

=head1 COPYRIGHT

Copyright (C) 2020-2021 Dan Church.
License GPLv3+: GNU GPL version 3 or later (L<http://gnu.org/licenses/gpl.html>).
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

=cut

use Getopt::Long qw/ GetOptions /;
use Pod::Usage qw/ pod2usage /;

# :squash-ignore-start:
# (this prepends to the load path)
use File::Basename  qw/ dirname /;
use Cwd             qw/ realpath /;
use lib &dirname(&realpath($0));

require Prompt;
# :squash-ignore-end:

our $VERSION = '1.0.1';

MAIN: {
    my (
        $basic_git,
        $err_color,
        $frame_color,
        $git,
        $help,
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
        'help' => \$help,
        'no-git' => \$no_git,
        'basic-git' => \$basic_git,
        'user-color=s' => \$user_color, 'u=s' => \$user_color,
        'host-color=s' => \$host_color, 'h=s' => \$host_color,
        'frame-color=s' => \$frame_color, 'f=s' => \$frame_color,
        'strudel-color=s' => \$strudel_color, 's=s' => \$strudel_color,
        'err-color=s' => \$err_color, 'e=s' => \$err_color,
    ) || &pod2usage(
        -exitval => 2,
        -msg => "Try '$0 --help' for more information",
    );

    &pod2usage(
        -verbose => 1,
        -exitval => 0,
    ) if $help;

    $git = 0 if defined $no_git;
    $utf8 = 0 if defined $no_utf8;

    # default: green / yellow
    if ($ENV{USER} eq 'root') {
        $host_color = '3' unless defined $host_color;
        $user_color = '3:b' unless defined $user_color;
    } else {
        $host_color = '2' unless defined $host_color;
        $user_color = '2:b' unless defined $user_color;
    }

    my $prompt = Prompt->new(
        utf8 => $utf8,
        colors => {
            host => $host_color,
            user => $user_color,
            frame => $frame_color,
            strudel => $strudel_color,
            err => $err_color,
        },
        features => {
            git => $git,
        },
        basic_git => $basic_git,
    );

    binmode(STDOUT, ":utf8");
    print $prompt, "\n";
}
