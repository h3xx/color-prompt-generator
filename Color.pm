package Color;
# vi: et sts=4 sw=4 ts=4
use strict;
use warnings;

sub new {
    my $class = shift;
    bless {
        bg => 0,
        bold => 0,
        fg => 7,
        mode => 'normal',
        underline => 0,
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
