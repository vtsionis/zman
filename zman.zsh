#!/usr/bin/env zsh

0=${(%):-%x}

fpath=(${0:A:h}/completions $fpath)
ZMAN_DIR=${0:A:h}
ZMAN_PLUGINS_DIR=$ZMAN_DIR/plugins

ZMAN_LOADED_PLUGINS=()

function _zman_notify () {
    local message=$1
    local level=${2:-info}
    local delay=${3:-0}

    local logo="%F{blue}ZMAN%f"

    case $level in
        error) level="%F{red}$level%f" ;;
        warning) level="%F{yellow}$level%f" ;;
        success) level="%F{green}$level%f" ;;
        note) level="%F{magenta}$level%f" ;;
        info | *) level="%F{cyan}$level%f" ;;
    esac

    print -P "$logo $level $1" && sleep $delay
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
        "\nls\t\t\tList all installed plugins and their status."
        "\npurge\t[all]\t\tRemove installed but not loaded plugins."
        "\t\t\tWhen %F{yellow}all%f is specified, all installed plugins are removed"
        "\t\t\tregardless if they are loaded or not. This is an easy way to clean up"
        "\t\t\tthe plugins directory and start fresh."
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
    git -C $ZMAN_DIR pull --quiet 2>/dev/null
    local _updated=$?

    if (( $_updated == 0 )); then
        local currently_loaded_plugins=$ZMAN_LOADED_PLUGINS
        . $ZMAN_DIR/zman.zsh
        ZMAN_LOADED_PLUGINS=$currently_loaded_plugins
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

function _zman_plugin_ls () {
    setopt LOCAL_OPTIONS NULL_GLOB # Ignore errors due to an empty Plugins directory

    _zman_notify "List of installed plugins\n" info 0

    local output=("%U%F{cyan}Plugin%f%u" "%U%F{cyan}Loaded%f%u")

    for plugin in $ZMAN_PLUGINS_DIR/*; do
        local name=${${plugin:t}//_SLASH_/\/}

        output+=($name)
        if (( ${ZMAN_LOADED_PLUGINS[(Ie)$name]} != 0 )); then
            output+=("%F{green}  %f")
        else
            output+=("%F{red}  ✗%f")
        fi
    done

    if (( ${#output} == 2 )); then
        _zman_notify "No plugin is installed." note 0
    else
        print -a -C 2 -P $output
    fi
}

function _zman_plugin_purge () {
    setopt LOCAL_OPTIONS NULL_GLOB # Ignore errors due to an empty Plugins directory

    local output=("\n%U%F{cyan}Purged Plugins%f%u")

    for plugin in $ZMAN_PLUGINS_DIR/*; do
        local name=${${plugin:t}//_SLASH_/\/}

        if [[ $1 == all ]] || (( ${ZMAN_LOADED_PLUGINS[(Ie)$name]} == 0 )); then
            rm -rf $plugin
            local _removed=$?
            if (( $_removed == 0 )); then
                output+=($name)
            fi
        fi
    done

    if (( ${#output} == 1 )); then
        _zman_notify "No plugin was purged." note 0
    else
        print -a -C 1 -P $output
    fi
}

function _zman_plugin_update () {
    setopt LOCAL_OPTIONS NULL_GLOB # Ignore errors due to an empty Plugins directory

    for plugin in $ZMAN_PLUGINS_DIR/*; do
        local name=${${plugin:t}//_SLASH_/\/}

        git -C $plugin pull --quiet 2>/dev/null
        local _updated=$?

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

        integrate) _zman_integrate ;;

        ls) _zman_plugin_ls ;;

        load) _zman_plugin_load ${@:2} ;;

        purge) _zman_plugin_purge $2;;

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

