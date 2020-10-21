package Prompt;
# vi: et sts=4 sw=4 ts=4
use strict;
use warnings;
use overload '""' => 'to_string';

require Color;
require Color::Transform::State;

sub new {
    my $class = shift;

    my $self = bless {
        @_,
    }, $class;

    $self->{frame_color} = Color->new(
        bold => 1,
        fg => 0,
    ) unless defined $self->{frame_color};

    $self
}

sub host_color {
    my $self = shift;
    if (@_ > 0) {
        $self->{host_color} = $_[0];
    }
    $self->{host_color}
}

sub user_color {
    my $self = shift;
    if (@_ > 0) {
        $self->{user_color} = $_[0];
    }
    $self->{user_color}
}

sub git {
    my $self = shift;
    if (@_ > 0) {
        $self->{git} = $_[0];
    }
    $self->{git}
}

sub frame_color {
    my $self = shift;
    if (@_ > 0) {
        $self->{frame_color} = $_[0];
    }
    $self->{frame_color}
}

sub frame_color_box {
    my $self = shift;
    Color->new(%{$self->frame_color}, mode => 'G1');
}

sub blocker {
    my $self = shift;
    if ($self->{demo}) {
        return sub {
            join '', @_;
        };
    }
    return sub {
        foreach my $arg (@_) {
            if (ref $arg eq 'Color::Transform') {
                $arg->escaped;
            }
        }
        sprintf '\[%s\]', join '', @_
    };
}

sub line1_frame {
    my $self = shift;
    my $state = shift;

    my $strudel_color = Color->new(
        bg => 0,
        bold => 0,
        fg => 7,
        underline => 0,
    );
    my $blocker = $self->blocker;

    my $out = &{$blocker}(
        '\e)0', # \e)0 sets G1 to special characters,
        $state->next($self->frame_color_box)->update, # (turn on box drawing)
    );

    $out .= 'lqqu'
        . &$blocker($state->next($self->frame_color)->update) # (turn off box drawing)
        . '\l ' # TTY number
        . &$blocker($state->next($self->user_color)->update)
        . '\u'
        . &$blocker($state->next($strudel_color)->update)
        . '@'
        . &$blocker($state->next($self->host_color)->update)
        . '\h'
        ;

    $out

}

sub line1_mid {
    my $self = shift;
    my $state = shift;

    my $blocker = $self->blocker;

    my $out =
        &$blocker($state->next($self->frame_color_box)->update) # (turn on box drawing)
        . ' tq\\`'
        . &$blocker($state->next($self->frame_color)->update) # (turn off box drawing)
        ;

    $out
}

sub err {
    my $self = shift;
    my $state = shift;

    my $err_color = Color->new(
        fg => 222,
        bg => 235,
        bold => 1,
    );

    my $out = '$(err=$?; [[ $err -eq 0 ]] || printf \' \[%s\][%d]\' \''
        . $state->next($err_color)->update->escaped
        . '\' $err)'
        ;

    $out
}

sub line2_frame {
    my $self = shift;
    my $state = shift;
    my $blocker = $self->blocker;
    my $pwd_color = Color->new(
        fg => 7,
        bg => 0,
        underline => 0,
        bold => 0,
    );
    my $dollar_color = Color->new(
        bg => 0,
        bold => 1,
        fg => 7,
        underline => 0,
    );
    $state->reset;
    my $out =
        &$blocker('\n', $state->next($self->frame_color_box)->update->with_reset)
        . 'mq[ '
        . &$blocker($state->next($pwd_color)->update)
        . '\w'
        . &$blocker($state->next($self->frame_color)->update)
        . ' ]= '
        . &$blocker($state->next($dollar_color)->update)
        . '\$'
        . &$blocker($state->next(Color->new)->update->with_reset)
        . ' '
}

sub to_string {
    my $self = shift;

    # FIXME remove
    $self->{demo} = 0;

    my $state = Color::Transform::State->new;

#    sprintf "__git_ps1 '%s'\n'%s'\"%s\"\n'\\n%s' ' %%s'",
#        $self->line1_frame($state),
#        $self->line1_mid($state),
#        $self->err($state),
#        $self->line2_frame($state)
#        ;
    sprintf "__git_ps1 '%s' '%s'\"%s\"'%s' ' %%s'",
        $self->line1_frame($state),
        $self->line1_mid($state),
        $self->err($state),
        $self->line2_frame($state)

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
