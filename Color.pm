package Color;
# vi: et sts=4 sw=4 ts=4
use strict;
use warnings;

require Color::Transform;

sub new {
    my $class = shift;
    bless {
        mode => 'normal',
        @_,
    }, $class
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
