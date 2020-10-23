package Prompt;
# vi: et sts=4 sw=4 ts=4
use strict;
use warnings;
use overload '""' => 'to_string';

require Color;
require Color::Transform::State;

sub new {
    my $class = shift;

    bless {
        frame_color => Color->new(
            bold => 1,
            fg => 0,
        ),
        tty_color => Color->new(
            bold => 1,
            fg => 0,
        ),
        err_color => Color->new(
            fg => 222,
            bg => 235,
            bold => 1,
        ),
        strudel_color => Color->new(
            bg => 0,
            bold => 0,
            fg => 7,
            underline => 0,
        ),
        @_,
    }, $class
}

sub frame_color_box {
    my $self = shift;
    Color->new(%{$self->{frame_color}}, mode => 'G1');
}

sub blocker {
    foreach my $arg (@_) {
        if (ref $arg eq 'Color::Transform') {
            $arg->escaped;
        }
    }
    my $str = join '', @_;
    length $str ? "\\[$str\\]" : '';
}

sub line1_frame_left {
    my ($self, $state) = @_;
    if ($self->{utf8}) {
        &blocker($state->next($self->{frame_color}))
        . "\x{250c}\x{2500}\x{2500}\x{2524}"
    } else {
        &blocker(
            '\e)0', # \e)0 sets G1 to special characters,
            $state->next($self->frame_color_box), # (turn on box drawing)
        )
        . 'lqqu'
    }
}

sub line1_left {
    my ($self, $state) = @_;

    return
        $self->line1_frame_left($state)
        . &blocker($state->next($self->{tty_color}))
        . '\l ' # TTY number
        . &blocker($state->next($self->{user_color}))
        . '\u'
        . &blocker($state->next($self->{strudel_color}))
        . '@'
        . &blocker($state->next($self->{host_color}))
        . '\h'
}

sub line1_right {
    my ($self, $state) = @_;

    if ($self->{utf8}) {
        &blocker($state->next($self->{frame_color}))
        . " \x{251c}\x{2500}\x{25c6}"
    } else {
        &blocker($state->next($self->frame_color_box)) # (turn on box drawing)
        . ' tq\\`'
        . &blocker($state->next($self->{frame_color})) # (turn off box drawing)
    }
}

sub err {
    my ($self, $state) = @_;
    return
        q~$(err=$?; [[ $err -eq 0 ]] || printf ' \[%s\][%d]' '~
        . $state->next($self->{err_color})->escaped
        . q~' $err)~
}

sub line2_frame_left {
    my ($self, $state) = @_;

    if ($self->{utf8}) {
        &blocker($state->next($self->{frame_color})->with_reset)
        . "\x{2514}\x{2500}["
    } else {
        &blocker($state->next($self->frame_color_box)->with_reset)
        . 'mq['
    }
}

sub line2 {
    my ($self, $state) = @_;
    my $pwd_color = Color->new;
    my $dollar_color = Color->new(bold => 1);
    $state->reset;
    return
        '\n'
        . $self->line2_frame_left($state)
        . ' '
        . &blocker($state->next($pwd_color))
        . '\w'
        . &blocker($state->next($self->{frame_color}))
        . ' ]= '
        . &blocker($state->next($dollar_color))
        . '\$'
        . &blocker($state->next(Color->new)->with_reset)
        . ' '
}

sub git_prompt {
    my $self = shift;
    (my $p = $self->git_prompt_command) =~ s/'/'\\''/g;
    sprintf q~PROMPT_COMMAND='%s'~, $p;
}

sub git_prompt_command {
    my $self = shift;
    my $state = Color::Transform::State->new;
    sprintf q~__git_ps1 '%s' '%s'"%s"'%s' ' %%s'~,
        $self->line1_left($state),
        $self->line1_right($state),
        $self->err($state),
        $self->line2($state)
}

sub non_git_prompt {
    my $self = shift;
    (my $p = $self->non_git_ps1) =~ s/'/'\\''/g;
    sprintf q~PS1='%s'~, $p;
}

sub non_git_ps1 {
    my $self = shift;
    my $state = Color::Transform::State->new;
    $self->line1_left($state)
        . $self->line1_right($state)
        . $self->err($state)
        . $self->line2($state)
}

sub to_string {
    my $self = shift;
    $self->{git}
        ? $self->git_prompt
        : $self->non_git_prompt
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
