package Defaults;
# vi: et sts=4 sw=4 ts=4
use strict;
use warnings;

sub new {
    my $class = shift;
    my $self = bless {
        user => $ENV{USER},
    }, $class;
    $self
}

sub basic_git {
    return 0;
}

sub utf8 {
    return 0;
}

sub features {
    return (
        err => 1,
        tty => 1,
        git => 1,
        git_loader => 1,
    );
}

sub colors {
    my $self = shift;
    return (
        dollar => '7:-0:b',
        err => '222:-235:b',
        frame => '0:b',
        git_bad => '222:-235:b',
        git_default => '121:-235:b',
        git_flags => '81:-233:b',
        git_ok => '121:-235:b',
        pwd => '7:-0',
        strudel => '7:-0',
        tty => '0:b',
        host => $self->host_color,
        user => $self->user_color,
    );
}

sub host_color {
    # default: green (root) / yellow (non-root)
    return $_[0]->_is_root ? '3' : '2';
}

sub user_color {
    return $_[0]->host_color . ':b';
}

sub _is_root {
    return $_[0]->{user} eq 'root';
}

=head1 AUTHOR

Dan Church S<E<lt>h3xx@gmx.comE<gt>>

=head1 COPYRIGHT

Copyright (C) 2020-2022 Dan Church.

License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.

=cut

1;
