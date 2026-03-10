# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name: openssh
# @brief: Set the OpenSSH environment.
# @repository: https://github.com/johnstonskj/zsh-openssl-plugin
# @version: 0.1.1
# @license: MIT AND Apache-2.0
#
# Public variables:
#
# * `OPENSSL`; plugin-defined global associative array with the following keys:
#   * `_ALIASES`; a list of all aliases defined by the plugin.
#   * `_FUNCTIONS`; a list of all functions defined by the plugin.
#   * `_PLUGIN_DIR`; the directory the plugin is sourced from.
#   * `_OLD_KEY_PATH`; the previous value of the `SSH_KEY_PATH` environment variable.
# * `SSH_KEY_PATH`; OpenSSH key path.
#

############################################################################
# Standard Setup Behavior
############################################################################

# See https://wiki.zshell.dev/community/zsh_plugin_standard#zero-handling
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# See https://wiki.zshell.dev/community/zsh_plugin_standard#standard-plugins-hash
declare -gA OPENSSL
OPENSSL[_PLUGIN_DIR]="${0:h}"
OPENSSL[_FUNCTIONS]=""

# Saving the current state for any modified global environment variables.
OPENSSL[_OLD_KEY_PATH]="${SSH_KEY_PATH:-}"

############################################################################
# Internal Support Functions
############################################################################

#
# This function will add to the `OPENSSL[_FUNCTIONS]` list which is
# used at unload time to `unfunction` plugin-defined functions.
#
# See https://wiki.zshell.dev/community/zsh_plugin_standard#unload-function
# See https://wiki.zshell.dev/community/zsh_plugin_standard#the-proposed-function-name-prefixes
#
.openssl_remember_fn() {
    builtin emulate -L zsh

    local fn_name="${1}"
    if [[ -z "${OPENSSL[_FUNCTIONS]}" ]]; then
        OPENSSL[_FUNCTIONS]="${fn_name}"
    elif [[ ",${OPENSSL[_FUNCTIONS]}," != *",${fn_name},"* ]]; then
        OPENSSL[_FUNCTIONS]="${OPENSSL[_FUNCTIONS]},${fn_name}"
    fi
}
.openssl_remember_fn .openssl_remember_fn

#
# This function does the initialization of variables in the global variable
# `OPENSSL`. It also adds to `path` and `fpath` as necessary.
#
openssl_plugin_init() {
    builtin emulate -L zsh
    builtin setopt extended_glob warn_create_global typeset_silent no_short_loops rc_quotes no_auto_pushd

    export SSH_KEY_PATH="~/.ssh/rsa_id"
}
.openssl_remember_fn openssl_plugin_init

############################################################################
# Plugin Unload Function
############################################################################

# See https://wiki.zshell.dev/community/zsh_plugin_standard#unload-function
openssl_plugin_unload() {
    builtin emulate -L zsh

    # Remove all remembered functions.
    local plugin_fns
    IFS=',' read -r -A plugin_fns <<< "${OPENSSL[_FUNCTIONS]}"
    local fn
    for fn in ${plugin_fns[@]}; do
        whence -w "${fn}" &> /dev/null && unfunction "${fn}"
    done

    # Reset global environment variables .
    export SSH_KEY_PATH="${OPENSSL[_OLD_KEY_PATH]}"

    # Remove the global data variable.
    unset OPENSSL

    # Remove this function.
    unfunction openssl_plugin_unload
}

############################################################################
# Initialize Plugin
############################################################################

openssl_plugin_init

true
