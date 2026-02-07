#!/usr/bin/env zsh

0=${(%):-%x}

fpath=(${0:A:h}/completions $fpath)
ZMAN_DIR=${0:A:h}
ZMAN_PLUGINS_DIR=$ZMAN_DIR/plugins

export -a ZMAN_LOADED_PLUGINS=()

function _zman_notify () {
    local logo=ZMAN
    local message=$1
    local level=${2:-info}
    local delay=${3:-0}

    if [[ ! -v $ZMAN_NO_COLOR ]]; then
        logo="%K{black}%F{blue}$logo%f"

        case $level in
            error) level="%F{red}$level%f" ;;
            warning) level="%F{yellow}$level%f" ;;
            success) level="%F{green}$level%f" ;;
            note) level="%F{magenta}$level%f" ;;
            info | *) level="%F{cyan}$level%f" ;;
        esac
    fi

    print -P "$logo $level $1%k" && sleep $delay
}

function _zman_help () {
    local output=(
        "\n%F{cyan}NAME:%f"
        "zman - A minimalistic Zsh plugin manager"
        "\n%F{cyan}USAGE:%f"
        "zman <command> [arguments]"
        "\n%F{cyan}COMMANDS:%f"
        "help\t\t\tShow this menu."
        "\nload\t<plugin>\tLoad the corresponding plugin. Only Github plugins are supported."
        "\t\t\tThe plugin will be automatically installed if not present."
        "\t\t\tExample:"
        "\t\t\t%F{magenta}zman load zsh-users/zsh-completions%f"
        "\nupdate\t<target>\tStart the update process."
        "\n\t\t\tTo update Zman itself:"
        "\t\t\t%F{magenta}zman update self%f"
        "\n\t\t\tTo update all installed plugins:"
        "\t\t\t%F{magenta}zman update plugins%f"
        "\n\t\t\tTo update both Zman and all installed plugins:"
        "\t\t\t%F{magenta}zman update all%f"
    )

    print -l -P $output
}

function _zman_update () {
    local _updated=0
    git -C $ZMAN_DIR pull --quiet 2>/dev/null
    _updated=$?

    if (( $_updated == 0 )); then
        _zman_notify "Finished updating ZMAN" success
    else
        _zman_notify "Failed to update ZMAN" error
    fi
}

function _zman_plugin_load () {
    if [[ -z $1 ]]; then
        _zman_notify "A plugin name is required" error
        return
    fi

    setopt extendedglob
    if [[ $1 != ([^/]##)/([^/]##) ]]; then
        _zman_notify "Invalid plugin name. Expected <author>/<name>, but got \"$1\"" error
        return
    fi

    local _is_installed=0

    local plugin_dir=$ZMAN_PLUGINS_DIR/${1//\//_SLASH_}
    if [[ ! -d $plugin_dir ]]; then
        _zman_notify "Installing plugin \"$1\""
        _zman_notify "Destination: $plugin_dir" info 1

        mkdir -p $ZMAN_PLUGINS_DIR
        git clone --depth=1 --quiet https://github.com/$1 $plugin_dir 2>/dev/null
        _is_installed=$?

        if (( $_is_installed == 0 )); then
            _zman_notify "Finished installing plugin \"$1\"\n" success 1
        else
            _zman_notify "Failed to install plugin \"$1\"\n" error 1
        fi
    fi

    if (( ${ZMAN_LOADED_PLUGINS[(Ie)$1]} == 0 )); then
        (( $_is_installed == 0 )) && . $plugin_dir/*.zsh
        ZMAN_LOADED_PLUGINS+="$1"
    else
        _zman_notify "Plugin \"$1\" is already loaded" note
    fi
}

function _zman_plugin_update () {
    setopt NULL_GLOB # Ignore errors due to an empty Plugins directory

    for plugin in $ZMAN_PLUGINS_DIR/*; do
        local name=${${plugin:t}//_SLASH_/\/}

        local _updated=0
        git -C $plugin pull --quiet 2>/dev/null
        _updated=$?

        if (( $_updated == 0 )); then
            _zman_notify "Finished updating plugin \"$name\"" success
        else
            _zman_notify "Failed to update plugin \"$name\"" error
        fi
    done
}

function zman () {
    emulate -L zsh

    case $1 in
        help) _zman_help ;;

        load) _zman_plugin_load ${@:2} ;;

        update)
            case $2 in
                self) _zman_update ;;

                plugins) _zman_plugin_update ;;

                all)
                    _zman_update
                    _zman_plugin_update
                    ;;

                *) _zman_notify "Invalid update target: \"$2\"" warning ;;
            esac
            ;;

        *)
            _zman_notify "Unknown command \"$1\"" warning
            _zman_help
            ;;
    esac
}

