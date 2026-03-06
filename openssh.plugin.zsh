# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name openssh
# @brief Zsh plugin to set up OpenSSH environment.
# @repository https://github.com/johnstonskj/zsh-openssl-plugin
#
# ### Public Variables
#
# * `SSH_KEY_PATH`; OpenSSH key path.
#

############################################################################
# @section Lifecycle
# @description Plugin lifecycle functions.
#

openssl_plugin_init() {
    builtin emulate -L zsh

    @zplugins_envvar_save openssl SSH_KEY_PATH
    export SSH_KEY_PATH="~/.ssh/rsa_id"
}

# @internal
openssl_plugin_unload() {
    builtin emulate -L zsh

    @zplugins_envvar_restore openssl SSH_KEY_PATH
}
