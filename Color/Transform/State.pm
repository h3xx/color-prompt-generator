package Color::Transform::State;
# vi: et sts=4 sw=4 ts=4
use strict;
use warnings;

require Color;

sub new {
    my $class = shift;

    my $self = bless {
        @_,
    }, $class;

    $self->{curr_color} = Color->new
        unless defined $self->{curr_color};

    $self
}

sub reset {
    my $self = shift;
    $self->{curr_color} = Color->new;
}

sub flush {
    my $self = shift;
    if (defined $self->{next_color}) {
        my $nc = Color->new(
            %{$self->{curr_color}},
            %{$self->{next_color}},
        );
        $self->{curr_color} = $nc;
        $self->{next_color} = undef;
    }
}

sub next {
    my $self = shift;
    $self->{next_color} = shift;
    #$self->snapshot
    $self
}

sub snapshot {
    my $self = shift;
    return Color::Transform::State->new(%{$self});
}

sub update {
    my $self = shift;
    my $ret = Color::Transform->new_from_colors($self->{curr_color}, $self->{next_color});
    $self->flush;
    return $ret;
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
