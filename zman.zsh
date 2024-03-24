# Bootstrap Zman as the plugin manager

typeset -gx A zsh_loaded_plugins=()

builtin autoload -Uz ${0:A:h}/functions/_zman_setup
_zman_setup

