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
        @_,
    }, $class
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
    foreach my $arg (@_) {
        if (ref $arg eq 'Color::Transform') {
            $arg->escaped;
        }
    }
    sprintf '\[%s\]', join '', @_;
}

sub line1_frame {
    my ($self, $state) = @_;

    my $strudel_color = Color->new(
        bg => 0,
        bold => 0,
        fg => 7,
        underline => 0,
    );

    return
        &blocker(
            '\e)0', # \e)0 sets G1 to special characters,
            $state->next($self->frame_color_box), # (turn on box drawing)
        )
        . 'lqqu'
        . &blocker($state->next($self->frame_color)) # (turn off box drawing)
        . '\l ' # TTY number
        . &blocker($state->next($self->user_color))
        . '\u'
        . &blocker($state->next($strudel_color))
        . '@'
        . &blocker($state->next($self->host_color))
        . '\h'
}

sub line1_mid {
    my ($self, $state) = @_;

    return
        &blocker($state->next($self->frame_color_box)) # (turn on box drawing)
        . ' tq\\`'
        . &blocker($state->next($self->frame_color)) # (turn off box drawing)
}

sub err {
    my ($self, $state) = @_;

    my $err_color = Color->new(
        fg => 222,
        bg => 235,
        bold => 1,
    );

    return
        q~$(err=$?; [[ $err -eq 0 ]] || printf ' \[%s\][%d]' '~
        . $state->next($err_color)->escaped
        . q~' $err)~
}

sub line2_frame {
    my ($self, $state) = @_;
    my $pwd_color = Color->new;
    my $dollar_color = Color->new(bold => 1);
    $state->reset;
    return
        '\n'
        . &blocker($state->next($self->frame_color_box)->with_reset)
        . 'mq[ '
        . &blocker($state->next($pwd_color))
        . '\w'
        . &blocker($state->next($self->frame_color))
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
        $self->line1_frame($state),
        $self->line1_mid($state),
        $self->err($state),
        $self->line2_frame($state)
}

sub non_git_prompt {
    my $self = shift;
    (my $p = $self->non_git_ps1) =~ s/'/'\\''/g;
    sprintf q~PS1='%s'~, $p;
}

sub non_git_ps1 {
    my $self = shift;
    my $state = Color::Transform::State->new;
    $self->line1_frame($state)
        . $self->line1_mid($state)
        . $self->err($state)
        . $self->line2_frame($state)
}

sub to_string {
    my $self = shift;
    $self->git
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
