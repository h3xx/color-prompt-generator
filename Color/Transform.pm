package Color::Transform;
# vi: et sts=4 sw=4 ts=4
use strict;
use warnings;
use overload '""' => 'to_string';

use constant DEFAULT_FG => 7;
use constant DEFAULT_BG => 0;
use constant DEFAULT_MODE => 'normal';

require Color;

sub new {
    my $class = shift;
    bless {
        actions => [],
        escaped => 0,
        @_,
    }, $class
}

sub new_from_colors {
    my $class = shift;
    my ($from, $to) = @_;

    $from = Color->new unless defined $from;

    my $self = Color::Transform->new;

    if (defined $to->{bold}) {
        my $was_bold = (defined $from->{bold} ? $from->{bold} : 0);
        if ($was_bold != $to->{bold}) {
            $self->bold($to->{bold});

            # XXX if we unset bold, we have to set our color again because
            # unsetting bold involves resetting the color
            unless ($to->{bold}) {
                my $nf = Color->new;
                $nf->{mode} = $from->{mode} if defined $from->{mode};
                $from = $nf;
            }
        }
    }

    if (defined $to->{fg}) {
        my $was = (defined $from->{fg} ? $from->{fg} : DEFAULT_FG);
        if ($was != $to->{fg}) {
            $self->fg($to->{fg});
        }
    }

    if (defined $to->{bg}) {
        my $was = (defined $from->{bg} ? $from->{bg} : DEFAULT_BG);
        if ($was != $to->{bg}) {
            $self->bg($to->{bg});
        }
    }

    if (defined $to->{mode} or defined $from->{mode}) {
        my $was = (defined $from->{mode} ? $from->{mode} : DEFAULT_MODE);
        my $is = (defined $to->{mode} ? $to->{mode} : DEFAULT_MODE);
        if ($was ne $is) {
            $self->mode($is);
        }
    }

    $self
}

sub with_reset {
    my $self = shift;
    if (@{$self->{actions}} < 1 || $self->{actions}->[0] != 0) {
        unshift @{$self->{actions}}, 0;
    }
    $self
}

sub bold {
    my $self = shift;
    $self->_push($_[0] ? 1 : 0);
}

sub fg {
    my $self = shift;
    if ($_[0] < 16) {
        $self->_push($_[0] + 30);
    } else {
        $self->_push(38, 5, $_[0]);
    }
}

sub bg {
    my $self = shift;
    if ($_[0] < 16) {
        $self->_push($_[0] + 40);
    } else {
        $self->_push(48, 5, $_[0]);
    }
}

sub mode {
    my $self = shift;
    if ($_[0] eq 'G1') {
        $self->{after} = {
            unescaped => "\016",
            escaped => '\016',
        };
    } else {
        # Normal
        $self->{after} = {
            unescaped => "\017",
            escaped => '\017',
        };
    }
}

sub _push {
    my $self = shift;
    push @{$self->{actions}}, @_;
}

sub escaped {
    my $self = shift;
    push @_, 1; # default turn on escaping
    $self->{escaped} = shift;
    $self
}

sub to_string {
    my $self = shift;
    my $out = '';
    if (@{$self->{actions}}) {
        $out .= sprintf "%s[%sm",
            ($self->{escaped} ? '\e' : "\e"),
            (join ';', @{$self->{actions}}),
    }
    if (defined $self->{after}) {
        $out .= (
            $self->{escaped}
                ? $self->{after}->{escaped}
                : $self->{after}->{unescaped}
        );
    }
    $out
}

=head1 AUTHOR

Dan Church S<E<lt>h3xx@gmx.comE<gt>>

=head1 COPYRIGHT

Copyright (C) 2020 Dan Church.

License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.

=cut

1;
