#!/usr/bin/env zsh

0=${(%):-%x}

ZMAN_DIR=${0:A:h}
ZMAN_PLUGINS_DIR=${ZMAN_PLUGINS_DIR:-$ZMAN_DIR/plugins}
ZMAN_LOADED_PLUGINS=()

fpath=($ZMAN_DIR/completions $fpath)

function _zman_util_notify () {
    emulate -L zsh

    local message=$1
    local level=${2:-info}
    local delay=${3:-0}

    typeset -A colors=(
        [error]=red
        [warning]=yellow
        [success]=green
        [note]=magenta
        [info]=cyan
    )

    local new_line=""
    if [[ $message[1,2] == "\n" ]]; then
        new_line="\n"
        message=$message[3,-1]
    fi

    print -P "$new_line%F{blue}ZMAN%f %F{${colors[$level]:-white}}${(r(7)( ))level}%f $message" && sleep $delay
}

function _zman_help () {
    emulate -L zsh

    local cmd=$1

    case $cmd in
        install | load | ls | purge | remove | update | version) ;;
        "")
            print -P "
%F{blue}ZMAN%f is a minimalistic Zsh plugin manager.

%F{cyan}USAGE:%f\n
zman <command> [OPTIONS] [arguments]

%F{cyan}Supported commands:%f\n
install     install a plugin
load        load a plugin
ls          list all plugins
purge       remove plugins
remove      remove a plugin
update      start update process
version     print current Zman version

Run 'zman help <command>' for more information about a command.

%F{cyan}Supported plugins:%f\n
Many of the above commands accept a %F{magenta}<plugin-name>%f as their argument.
Below are all the currently supported plugins and the expected format
for their name.

- %F{green}Git plugins:%f
  The %F{magenta}<plugin-name>%f format should be \"<author>/<repository-name>\".

- %F{green}Oh-My-Zsh plugins:%f
  The %F{magenta}<plugin-name>%f format should be \"ohmyzsh/<plugin-directory-name>\".

- %F{green}Local plugins:%f
  The %F{magenta}<plugin-name>%f should be an absolute path of the plugin's directory,
  starting with either \"/\" or \"~\".
"
            return 0
            ;;
        *)
            _zman_util_notify "Unknown help command \"$cmd\"" error
            _zman_util_notify "Run 'zman help' to display the help menu"
            return 1
            ;;
    esac

    typeset -A commands=(
        [install]="zman install [OPTIONS] <plugin-name>"
        [load]="zman load <plugin-name>"
        [ls]="zman ls"
        [purge]="zman purge [OPTIONS]"
        [remove]="zman remove <plugin-name>"
        [update]="zman update <target>"
        [version]="zman version"
    )

    typeset -A descriptions=(
        [install]="
Install the specified plugin. If the plugin is already installed, Zman
will do nothing, unless the %F{yellow}--force%f option is also preset. Git and
Oh-My-Zsh plugins are supported. For the format of the %F{magenta}<plugin-name>%f
see 'zman help'."
        [load]="
Load the specified plugin. If the plugin is not installed, automatically
install it. Git, Oh-My-Zsh and local plugins are supported. For the
format of the %F{magenta}<plugin-name>%f see 'zman help'."
        [ls]="
List all installed plugins in a table format. The first columns contains
the name of the plugin while the second indicates whether the plugin is
loaded or not."
        [purge]="
Remove all installed plugins that are not loaded in the current session.
If the %F{yellow}--all%f option is preset, all installed plugins will be
removed regardless if they are loaded or not. This is an easy way to
clean up the plugins directory and start fresh. Similar to other commands,
this is not applicable to local plugins."
        [remove]="
Remove the specified plugin. If the plugin was loaded, you need to start
a new session to stop the effect of the removed plugin. Only Git and
Oh-My-Zsh plugins are supported. Git and Oh-My-Zsh plugins are supported.
For the format of the %F{magenta}<plugin-name>%f see 'zman help'."
        [update]="
Update Zman itself, a single or all installed plugins, or everything
at once depending on which %F{magenta}<target>%f is specified.

%F{cyan}Supported targets:%f

- %F{magenta}self%f
  Update Zman itself, adhering to the branch in use.

- %F{magenta}<plugin-name>%f
  Update a Git or Oh-My-Zsh plugin. See 'zman help' for the expected
  format.

- %F{magenta}plugins%f
  Update all Git and Oh-My-Zsh installed plugins.

- %F{magenta}everything%f
  Update both Zman itself and the installed plugins in one go."
        [version]="
Print information about the currently running version of Zman.
This will also check if there is a newer version available."
    )

    typeset -A options=(
        [install]="
-f, --force     Reinstall the plugin in case it is already installed."
        [purge]="
-a, --all       Remove all installed plugins."
    )

    typeset -A examples=(
        [install]="
zman install zsh-users/zsh-autosuggestions
zman install ohmyzsh/1password
zman install -f zsh-users/zsh-completions"
        [load]="
zman load zsh-users/zsh-autosuggestions
zman load ohmyzsh/1password
zman load /path/to/your/plugin
zman load ~/my-awesome-plugin"
        [purge]="
zman purge
zman purge -a
zman purge --all"
        [remove]="
zman remove zsh-users/zsh-autosuggestions
zman remove ohmyzsh/1password"
        [update]="
zman update self
zman update ohmyzsh/git
zman update zsh-users/zsh-autosuggestions
zman update plugins
zman update everything"
    )

    local output="
%F{cyan}COMMAND:%f
\n$commands[$cmd]

%F{cyan}DESCRIPTION:%f
$descriptions[$cmd]"

    if [[ -n $options[$cmd] ]]; then
        output+="

%F{cyan}OPTIONS:%f
$options[$cmd]"
    fi
    if [[ -n $examples[$cmd] ]]; then
        output+="

%F{cyan}EXAMPLES:%f
$examples[$cmd]"
    fi

    _zman_util_notify "Usage of 'zman $cmd'"
    print -P $output
}

function _zman_version () {
    emulate -L zsh

    local branch=$(git -C $ZMAN_DIR branch --show-current --quiet 2>/dev/null)
    local commit=$(git -C $ZMAN_DIR log -n 1 $branch --format="%H" 2>/dev/null)
    local commits_behind=$(git rev-list --count HEAD..origin/$branch 2>/dev/null)

    local output=(
        "%F{cyan}Branch:%f" $branch
        "%F{cyan}Commit:%f" $commit
        "%F{cyan}Status:%f"
    )

    if (( $commits_behind )); then
        output+=(
            "%F{yellow}You are $commits_behind commit$([[ $commits_behind > 1 ]] && print s || print "") behind origin%f"
            " " " "
            "%F{magenta}Hint:%f" "Run 'zman update self' to update to the latest version of Zman"
        )
    else
        output+=("%F{green}Running on the latest version%f")
    fi

    print -P -n "%F{blue}"
    echo -e "
 _____
|__  / _ __ ___    __ _  _ __
  / / | '_ \` _ \\  / _\` || '_ \\
 / /_ | | | | | || (_| || | | |
/____||_| |_| |_| \__,_||_| |_|
"
  print -a -C 2 -P $output
}

function _zman_util_plugin_unload () {
    emulate -L zsh

    local index=${ZMAN_LOADED_PLUGINS[(Ie)$1]}
    (( $index )) && ZMAN_LOADED_PLUGINS[$index]=() || return 0
}

function _zman_util_plugin_install_git () {
    emulate -L zsh

    local plugin=$1
    local directory=$2

    _zman_util_notify "\nInstalling plugin \"$plugin\""
    _zman_util_notify "Destination: $directory" info 1

    mkdir -p $directory

    # Catch a Ctrl+C signal
    trap : INT; git clone --depth=1 --quiet https://github.com/$plugin $directory|| ( return 1 )

    if (( $? )); then
        rm -rf $directory

        _zman_util_notify "\nFailed to install plugin \"$plugin\"" error 1
        _zman_util_plugin_unload $plugin
        return 1
    fi

    _zman_util_notify "Finished installing plugin \"$1\"" success 1
}

function _zman_util_plugin_install_omz () {
    emulate -L zsh

    local plugin_name=$1
    local directory=$2

    _zman_util_notify "\nInstalling Oh-My-Zsh plugin \"$plugin_name\""
    _zman_util_notify "Destination: $directory" info 1

    mkdir -p $directory

    git init --quiet $directory
    git -C $directory remote add -f origin "https://github.com/ohmyzsh/ohmyzsh.git" &>/dev/null
    git -C $directory config core.sparseCheckout true
    echo "plugins/$plugin_name" >> $directory/.git/info/sparse-checkout
    git -C $directory pull --quiet origin master

    if [[ ! -d $directory/plugins/$plugin_name ]]; then
        _zman_util_notify "Failed to install Oh-My-Zsh plugin \"$plugin_name\"" error
        _zman_util_notify "Make sure that the spelling of the plugin is correct" note 1
        _zman_util_plugin_unload ohmyzsh/$plugin_name
        rm -rf $directory
        return 1
    fi

    _zman_util_notify "Finished installing Oh-My-Zsh plugin \"$plugin_name\"" success 1
}

function _zman_self_update () {
    emulate -L zsh

    _zman_util_notify "\nUpdating Zman" info 1

    git -C $ZMAN_DIR pull origin $(git -C $ZMAN_DIR branch --show-current) --quiet 2>/dev/null
    local _updated=$?
    if (( $_updated )); then
        _zman_util_notify "Failed to update ZMAN" error
        return $_updated
    fi

    local currently_loaded_plugins=$ZMAN_LOADED_PLUGINS
    . $ZMAN_DIR/zman.zsh
    ZMAN_LOADED_PLUGINS=$currently_loaded_plugins

    _zman_util_notify "Finished updating ZMAN" success
}

function _zman_plugin_install () {
    emulate -L zsh
    setopt EXTENDED_GLOB

    local options=()
    local error_file=/tmp/zman_error_$(date +%Y%m%d_%H%M%S%N)
    zparseopts -F -D -E -a options f -force 2>$error_file
    local error=$(cat $error_file)
    rm -rf $error_file

    if [[ -n $error ]]; then
        _zman_util_notify "\nInvalid Option: ${error/*bad option\: /}" error
        return 1
    fi

    case $#@ in
        0)
            _zman_util_notify "\nMissing plugin name" error
            return 1
            ;;

        1)
            local plugin=${${1##[[:space:]]##}%%[[:space:]]##}

            if [[ ${plugin[1]} == "/" || ${plugin[1]} == "~" ]]; then
                _zman_util_notify "\nNo need to install a local plugin" warning
                _zman_util_notify "To use the plugin, simply load it with 'zman load $plugin'"
                return 0
            fi

            if [[ ${#plugin} == 0 ]]; then
                _zman_util_notify "\nEmpty plugin name" error
                return 1
            fi

            local directory=$ZMAN_PLUGINS_DIR/${plugin//\//_SLASH_}
            if [[ -d $directory ]]; then
                if (( ! $options[(Ie)-f] && ! $options[(Ie)--force] )); then
                    _zman_util_notify "\nPlugin \"$plugin\" is already installed" warning
                    _zman_util_notify "Use the -f|--force option to reinstall it"
                    return 0
                fi
                rm -rf $directory
            fi

            if [[ $plugin =~ ^ohmyzsh/* ]]; then
                _zman_util_plugin_install_omz ${plugin/ohmyzsh\//} $directory
            else
                _zman_util_plugin_install_git $plugin $directory
            fi
            local _installed=$?
            if (( $_installed )); then
                return $_installed
            fi
            ;;

        *)
            _zman_util_notify "\nMore than 1 argument was provided" error
            _zman_util_notify "Arguments: $*"
            return 1
            ;;
    esac
}

function _zman_plugin_load () {
    emulate -L zsh
    setopt EXTENDED_GLOB
    setopt NULL_GLOB

    local plugin=${${1##[[:space:]]##}%%[[:space:]]##}

    if [[ -z $plugin ]]; then
        _zman_util_notify "\nMissing plugin name" error
        return 1
    fi

    local kind=git
    local directory

    if [[ ${plugin[1]} == "/" || ${plugin[1]} == "~" ]]; then
        kind="local"
        directory=$plugin
    else
        directory=$ZMAN_PLUGINS_DIR/${plugin//\//_SLASH_}

        if [[ $plugin =~ ^ohmyzsh/* ]]; then
            kind=omz
        fi
    fi

    local _installed=0
    if [[ ! -d $directory ]]; then
        case $kind in
            local)
                _zman_util_notify "\nNo such directory for local plugin: $directory" error
                _installed=1
                ;;

            omz)
                _zman_util_plugin_install_omz ${plugin/ohmyzsh\//} $directory
                _installed=$?
                ;;

            git)
                _zman_util_plugin_install_git $plugin $directory
                _installed=$?
                ;;
        esac

    fi

    if (( $_installed )); then
        _zman_util_plugin_unload $plugin
        return $_installed
    fi

    if [[ $kind == omz ]]; then
        . $directory/plugins/${plugin/ohmyzsh\//}/*.zsh
    else
        . $directory/*.zsh
    fi

    if (( ! ${ZMAN_LOADED_PLUGINS[(Ie)$plugin]} )); then
        ZMAN_LOADED_PLUGINS+=($plugin)
    fi
}

function _zman_util_plugin_update_git () {
    emulate -L zsh

    local plugin=$1
    local directory=$2

    local kind="plugin"
    if [[ $plugin =~ ^ohmyzsh/* ]]; then
        kind="Oh-My-Zsh plugin"
    fi

    _zman_util_notify "\nUpdating $kind \"$1\"" info 1

    git -C $directory pull origin $(git -C $directory branch --show-current) --quiet 2>/dev/null
    local _updated=$?
    if (( $_updated )); then
        _zman_util_notify "Failed to update $kind \"$1\"" error
        return $_updated
    fi

    _zman_util_notify "Finished updating $kind \"$1\"" success
}

function _zman_plugin_update () {
    emulate -L zsh
    setopt EXTENDED_GLOB

    local plugin=${${1##[[:space:]]##}%%[[:space:]]##}

    if [[ -z $plugin ]]; then
        _zman_util_notify "\nMissing plugin name" error
        return 1
    fi

    if [[ ${plugin[1]} == "/" || ${plugin[1]} == "~" ]]; then
        _zman_util_notify "\nCan't update a local plugin" warning 1
        return 1
    fi

    local directory=$ZMAN_PLUGINS_DIR/${plugin//\//_SLASH_}
    if [[ ! -d $directory ]]; then
        _zman_util_notify "\nPlugin \"$plugin\" is not installed" error 1
        return 1
    fi

    _zman_util_plugin_update_git ${plugin/ohmyzsh\//} $directory $kind
    return $?
}

function _zman_plugins_update () {
    emulate -L zsh
    setopt NULL_GLOB

    local _no_plugins=0
    for directory in $ZMAN_PLUGINS_DIR/*(/); do
        _no_plugins=1

        local plugin=${${directory:t}//_SLASH_/\/}
        _zman_util_plugin_update_git ${plugin/ohmyzsh\//} $directory
    done

    if (( ! $_no_plugins )); then
        _zman_util_notify "\nNo plugins are installed" warning
    fi
}

function _zman_plugins_list () {
    emulate -L zsh
    setopt NULL_GLOB

    typeset -A plugins=()
    for directory in $ZMAN_PLUGINS_DIR/*(/); do
        local plugin=${${directory:t}//_SLASH_/\/}
        plugins[$plugin]=" "
    done
    for plugin in $ZMAN_LOADED_PLUGINS; do
        plugins[$plugin]="✓"
    done

    local headers=(Plugin Loaded)
    local headers_length=$#headers
    local header_2_length=$#headers[2]

    local output=()
    local underline_extra_length=0
    for plugin in ${(kon)plugins}; do
        output+=($plugin "%F{green}${(l($header_2_length)( ))plugins[$plugin]}%f")

        local string_length=${#plugin}
        if (( $string_length > $underline_extra_length )); then
            underline_extra_length=$string_length
        fi
    done

    if (( ${#output} )); then
        _zman_util_notify "\nList of installed plugins\n"

        print -a -C $headers_length -P "%U%F{cyan}${(r($underline_extra_length)( ))headers[1]}" "$headers[2]%f%u"
        print -a -C $headers_length -P $output
    else
        _zman_util_notify "\nNo plugin is installed" warning
    fi
}

function _zman_plugins_purge () {
    emulate -L zsh
    setopt NULL_GLOB

    local options=()
    local error_file=/tmp/zman_error_$(date +%Y%m%d_%H%M%S%N)
    zparseopts -F -D -E -a options a -all 2>$error_file
    local error=$(cat $error_file)
    rm -rf $error_file

    if [[ -n $error ]]; then
        _zman_util_notify "\nInvalid Option: ${error/*bad option\: /}" error
        return 1
    fi

    if (( $#@ )); then
        _zman_util_notify "\nUnnecessary arguments were provided" error
        _zman_util_notify "Arguments: $*"
        return 1
    fi

    local all=0
    if (( $options[(Ie)-a] || $options[(Ie)--all] )); then
        all=1
    fi

    local output=("\n%U%F{cyan}Purged Plugins%f%u")

    for directory in $ZMAN_PLUGINS_DIR/*(/); do
        local plugin=${${directory:t}//_SLASH_/\/}
        if (( $all || ! ${ZMAN_LOADED_PLUGINS[(Ie)$plugin]} )); then
            rm -rf $directory
            if (( ! $? )); then
                output+=($plugin)

                if (( $all )); then
                    _zman_util_plugin_unload $plugin
                fi
            fi
        fi
    done

    if (( $#output == 1 )); then
        _zman_util_notify "\nNo plugin was purged"
    else
        print -a -C 1 -P $output
    fi
}

function _zman_plugin_remove () {
    emulate -L zsh
    setopt EXTENDED_GLOB

    local plugin=${${1##[[:space:]]##}%%[[:space:]]##}

    if [[ -z $plugin ]]; then
        _zman_util_notify "\nMissing plugin name" error
        return 1
    fi

    if [[ ${plugin[1]} == "/" || ${plugin[1]} == "~" ]]; then
        _zman_util_notify "\nCan't remove a local plugin" warning
        return 1
    fi

    local directory=$ZMAN_PLUGINS_DIR/${plugin//\//_SLASH_}
    if [[ ! -d $directory ]]; then
        _zman_util_notify "\nPlugin directory missing: $directory" warning
        return 1
    fi

    rm -rf $directory
    _zman_util_notify "\nFinished removing plugin \"$1\"" success

    if (( ${ZMAN_LOADED_PLUGINS[(Ie)$plugin]} )); then
        _zman_util_notify "Plugin \"$plugin\" is still loaded" warning
        _zman_util_notify "Start a new session to unloaded it" note
    fi
}

function zman () {
    emulate -L zsh

    case $1 in
        "" | help) _zman_help $2 ;;
        install) _zman_plugin_install ${@:2} ;;
        load) _zman_plugin_load $2 ;;
        ls) _zman_plugins_list ;;
        purge) _zman_plugins_purge ${@:2} ;;
        remove) _zman_plugin_remove $2 ;;
        update)
            case $2 in
                self) _zman_self_update ;;
                plugins) _zman_plugins_update ;;
                everything)
                    _zman_self_update
                    _zman_plugins_update
                    ;;
                "") _zman_util_notify "\nMissing update target" error ;;
                *) _zman_plugin_update $2 ;;
            esac
            ;;
        version) _zman_version ;;
        *)
            _zman_util_notify "\nUnknown command \"$1\"" error
            _zman_util_notify "Run 'zman help' to display the help menu"
            ;;
    esac
}

