# H3xx's fancy color prompt generator

![peon](/../flair/peon.png)
![root](/../flair/root.png)

## Installation

Clone this repo to `~/.color-prompt-generator`:

```sh
git clone https://github.com/h3xx/color-prompt-generator.git ~/.color-prompt-generator
```

Then add the following-lines to `~/.bashrc`:

```sh
if [[ ! -s ~/.bashrc-prompt ]]; then
    # 256-color vaporwave prompt
    # Root gets light neon blue
    # Non-root gets neon magenta
    [[ $UID -eq 0 ]] && USER_COLOR=45:b HOST_COLOR=39 || USER_COLOR=207:b HOST_COLOR=141

    GEN_ARGS=(
        --user-color="$USER_COLOR"
        --host-color="$HOST_COLOR"
    )

    if ! type -t git &>/dev/null; then
        GEN_ARGS+=(--no-git)
    fi
    if [[ $(locale charmap) = UTF-8 ]]; then
        GEN_ARGS+=(--utf8)
    fi

    ~/.color-prompt-generator/promptgen-main.pl \
        "${GEN_ARGS[@]}" \
        > ~/.bashrc-prompt

    # Clean up
    unset GEN_ARGS HOST_COLOR USER_COLOR
fi

. ~/.bashrc-prompt
```

## Different colors per host

For different prompts on different hosts, add some logic to your `.bashrc`:

```sh
if [[ ! -s ~/.bashrc-prompt ]]; then
    case "$HOSTNAME" in
        'myhost1')
            # 256-color vaporwave prompt
            # Root gets light neon blue
            # Non-root gets neon magenta
            [[ $UID -eq 0 ]] && USER_COLOR=45:b HOST_COLOR=39 || USER_COLOR=207:b HOST_COLOR=141
            ;;
        'myhost2')
            # 16-color prompt for this host
            # Root gets cyan (6)
            # Non-root gets green (2)
            [[ $UID -eq 0 ]] && USER_COLOR=6:b HOST_COLOR=6 || USER_COLOR=2:b HOST_COLOR=2
            ;;
        *)
            # default
            # Root gets yellow (3)
            # Non-root gets green (2)
            [[ $UID -eq 0 ]] && USER_COLOR=3:b HOST_COLOR=3 || USER_COLOR=2:b HOST_COLOR=2
            ;;
    esac

    GEN_ARGS=(
        --user-color="$USER_COLOR"
        --host-color="$HOST_COLOR"
    )

    if ! type -t git &>/dev/null; then
        GEN_ARGS+=(--no-git)
    fi
    if [[ $(locale charmap) = UTF-8 ]]; then
        GEN_ARGS+=(--utf8)
    fi

    ~/.color-prompt-generator/promptgen-main.pl \
        "${GEN_ARGS[@]}" \
        > ~/.bashrc-prompt

    # Clean up
    unset GEN_ARGS HOST_COLOR USER_COLOR
fi

. ~/.bashrc-prompt
```
