package Color::Transform::State;
# vi: et sts=4 sw=4 ts=4
use strict;
use warnings;

# :squash-ignore-start:
require Color;
require Color::Transform;
# :squash-ignore-end:

sub new {
    my $class = shift;

    bless {
        curr_color => Color->new,
        @_,
    }, $class
}

sub reset {
    my $self = shift;
    $self->{curr_color} = Color->new;
}

sub next_nonprinting {
    my ($self, $bg) = @_;
    $self->next(Color->new(%{$self->{curr_color}},
        bg => $bg,
        underline => 0,
    ))
}

sub next {
    my ($self, $next_color) = @_;
    my $ret = Color::Transform->new_from_colors($self->{curr_color}, $next_color);
    $self->{curr_color} = $next_color;
    return $ret;
}

=head1 AUTHOR

Dan Church S<E<lt>h3xx@gmx.comE<gt>>

=head1 COPYRIGHT

Copyright (C) 2020-2021 Dan Church.

License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.

=cut

1;
