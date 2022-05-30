package Prompt;
# vi: et sts=4 sw=4 ts=4
use strict;
use warnings;
use overload '""' => 'to_string';

# :squash-ignore-start:
require Color;
require Color::Transform;
require Color::Transform::State;
require Defaults;
# :squash-ignore-end:

sub new {
    my $class = shift;

    my $defaults = Defaults->new;
    my $self = bless {
        colors => {},
        features => {},
        space_bg => 0,
        basic_git => $defaults->basic_git,
        utf8 => $defaults->utf8,
        @_,
    }, $class;
    # Merge options
    delete @{$self->{features}}{ grep { not defined $self->{features}->{$_} } keys %{$self->{features}} };
    $self->{features} = {
        $defaults->features,
        (defined $self->{features} ? %{$self->{features}} : ()),
    };
    # Eliminate undef colors, apply default colors
    delete @{$self->{colors}}{ grep { not defined $self->{colors}->{$_} } keys %{$self->{colors}} };
    $self->{colors} = {
        $defaults->colors,
        %{$self->{colors}},
    };
    foreach my $key (keys %{$self->{colors}}) {
        $self->{colors}->{$key} = Color->from_string($self->{colors}->{$key})
            unless ref $self->{colors}->{$key};
    }

    $self
}

sub frame_color_box {
    my $self = shift;
    Color->new(%{$self->{colors}->{frame}}, mode => 'G1');
}

sub blocker {
    my $str = join '', @_;
    length $str ? "\\[$str\\]" : '';
}

sub line1_frame_left {
    my ($self, $state) = @_;
    if ($self->{utf8}) {
        &blocker($state->next($self->{colors}->{frame}))
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
        . (
            $self->{features}->{tty}
                # TTY number
                ? &blocker($state->next($self->{colors}->{tty})) . '\l'
                : ''
        )
        # Add a space, don't care what the foreground color is
        . &blocker($state->next_nonprinting($self->{space_bg}))
        . ' '
        . &blocker($state->next($self->{colors}->{user}))
        . '\u'
        . &blocker($state->next($self->{colors}->{strudel}))
        . '@'
        . &blocker($state->next($self->{colors}->{host}))
        . '\h'
}

sub line1_right {
    my ($self, $state) = @_;

    if ($self->{utf8}) {
        # Add a space, don't care what the foreground color is
        &blocker($state->next_nonprinting($self->{space_bg}))
        . ' '
        . &blocker($state->next($self->{colors}->{frame}))
        . "\x{251c}\x{2500}\x{25c6}"
    } else {
        # Add a space, don't care what the foreground color is
        &blocker($state->next_nonprinting($self->{space_bg}))
        . ' '
        . &blocker($state->next($self->frame_color_box)) # (turn on box drawing)
        . 'tq\\`'
        . &blocker($state->next($self->{colors}->{frame})) # (turn off box drawing)
    }
}

sub err {
    my ($self, $state) = @_;
    return
        q~$(err=$?; [[ $err -eq 0 ]] || printf ' \[%s\][%d]' '~
        . $state->next($self->{colors}->{err})
        . q~' $err)~
}

sub line2_frame_left {
    my ($self, $state) = @_;

    if ($self->{utf8}) {
        &blocker($state->next($self->{colors}->{frame})->with_reset)
        . "\x{2514}\x{2500}["
    } else {
        &blocker($state->next($self->frame_color_box)->with_reset)
        . 'mq['
    }
}

sub line2 {
    my ($self, $state) = @_;
    $state->reset;
    return
        '\n'
        . $self->line2_frame_left($state)
        # Add a space, don't care what the foreground color is
        . &blocker($state->next_nonprinting($self->{space_bg}))
        . ' '
        . &blocker($state->next($self->{colors}->{pwd}))
        . '\w'
        # Add a space, don't care what the foreground color is
        . &blocker($state->next_nonprinting($self->{space_bg}))
        . ' '
        . &blocker($state->next($self->{colors}->{frame}))
        . ']='
        # Add a space, don't care what the foreground color is
        . &blocker($state->next_nonprinting($self->{space_bg}))
        . ' '
        . &blocker($state->next($self->{colors}->{dollar}))
        . '\$'
        . &blocker($state->next(Color->new)->with_reset)
        . ' '
}

sub git_prompt_loader {
    my $self = shift;
    return undef unless $self->{features}->{git_loader};
    my @candidates = (
        '/usr/doc/git-*.*.*/contrib/completion/git-prompt.sh',
        '/usr/share/git-core/contrib/completion/git-prompt.sh',
        '/usr/lib/git-core/git-sh-prompt',
        '~/.git-prompt.sh',
    );
    foreach my $globstr (@candidates) {
        next unless grep { -f } glob $globstr;
        if ($globstr =~ /\*|\?|~/) {
            return sprintf
                'test -z "$(for fn in %s; do '
                . 'if [[ -f $fn ]]; then '
                . 'echo "$fn"; '
                . 'break; '
                . 'fi; '
                . 'done'
                . ')" || { . "$_"; }',
                $globstr
        } else {
            if (-f $globstr) {
                return ". $globstr"
            }
        }
    }
    return undef;
}

sub git_color_override {
    my $self = shift;
    my ($red, $green, $lblue) = @{$self->{colors}}{qw/ git_bad git_ok git_flags /};

    my $space = Color->new(bg => $self->{space_bg});
    # Taken from git-prompt.sh and made more compact
    q~__git_ps1_colorize_gitstring() {
local bad_color='~
    . &blocker(Color::Transform->new_from_colors($space, $red))
    . q~' ok_color='~
    . &blocker(Color::Transform->new_from_colors($space, $green))
    . q~' flags_color='~
    . &blocker(Color::Transform->new_from_colors($space, $lblue))
    . q~' c_clear='\[\e[0m\]' branch_color
[[ $detached = no ]] && branch_color=$ok_color || branch_color=$bad_color
c=$branch_color$c
z=$c_clear$z
[[ $w != '*' ]] || w=$bad_color$w
[[ -z $i ]] || i=$ok_color$i
[[ -z $s ]] || s=$flags_color$s
[[ -z $u ]] || u=$bad_color$u
r=$c_clear$r
}~;

}

# Basic git-enabled prompt; Will show you the branch or tag, but that's about
# it.
sub git_basic_ps1 {
    my ($self, $state) = @_;
    $self->line1_left($state)
        . '$(__git_ps1 \''
            . &blocker($state->next_nonprinting($self->{space_bg}))
            . ' '
            . &blocker($state->next($self->{colors}->{git_default}))
            . '%s\')'
        . $self->line1_right($state)
        . ($self->{features}->{err} ? $self->err($state) : '')
        . $self->line2($state)
}

sub git_prompt {
    my $self = shift;
    my @lines = (
        $self->git_prompt_loader,
    );
    my $state = Color::Transform::State->new;
    if ($self->{basic_git}) {
        (my $p = $self->git_basic_ps1($state)) =~ s/'/'\\''/g;
        push @lines, "PS1='$p'";
    } else {
        (my $p = $self->git_prompt_command($state)) =~ s/'/'\\''/g;
        push @lines,
            $self->git_color_override,
            'GIT_PS1_SHOWCOLORHINTS=1',
            "PROMPT_COMMAND='$p'";
    }
    join "\n", grep { defined $_ } @lines;
}

# Fancy git prompt; Shows branch, tag, special status, all in different colors
sub git_prompt_command {
    my ($self, $state) = @_;
    my $l1left = $self->line1_left($state);
    # The space before the git section is based on the last color state of the
    # line1_left. In order to color the space properly, we need to calculate it
    # just after.
    my $space_before_git_prompt = &blocker($state->next_nonprinting($self->{space_bg})) . ' ';
    sprintf q~__git_ps1 '%s' '%s'%s'%s' '%s%%s'~,
        $l1left,
        $self->line1_right($state),
        ($self->{features}->{err} ? '"' . $self->err($state) . '"' : ''),
        $self->line2($state),
        $space_before_git_prompt
}

sub non_git_prompt {
    my $self = shift;
    my $state = Color::Transform::State->new;
    (my $p = $self->non_git_ps1($state)) =~ s/'/'\\''/g;
    sprintf q~PS1='%s'~, $p;
}

sub non_git_ps1 {
    my ($self, $state) = @_;
    $self->line1_left($state)
        . $self->line1_right($state)
        . ($self->{features}->{err} ? $self->err($state) : '')
        . $self->line2($state)
}

sub to_string {
    my $self = shift;
    $self->{features}->{git}
        ? $self->git_prompt
        : $self->non_git_prompt
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
