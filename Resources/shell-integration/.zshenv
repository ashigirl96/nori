# vim:ft=zsh
#
# nori ZDOTDIR bootstrap for zsh.
#
# GhosttyKit already uses a ZDOTDIR injection mechanism for zsh (setting ZDOTDIR
# to Ghostty's integration dir). nori also needs to run its integration, but
# we must restore the user's real ZDOTDIR immediately so that:
# - /etc/zshrc sets HISTFILE relative to the real ZDOTDIR/HOME (shared history)
# - zsh loads the user's real .zprofile/.zshrc normally (no wrapper recursion)
#
# We restore ZDOTDIR from (in priority order):
# - GHOSTTY_ZSH_ZDOTDIR (set by GhosttyKit when it overwrote ZDOTDIR)
# - NORI_ZSH_ZDOTDIR (set by nori when it overwrote a user-provided ZDOTDIR)
# - unset (zsh treats unset ZDOTDIR as $HOME)

if [[ -n "${GHOSTTY_ZSH_ZDOTDIR+X}" ]]; then
    builtin export ZDOTDIR="$GHOSTTY_ZSH_ZDOTDIR"
    builtin unset GHOSTTY_ZSH_ZDOTDIR
elif [[ -n "${NORI_ZSH_ZDOTDIR+X}" ]]; then
    builtin export ZDOTDIR="$NORI_ZSH_ZDOTDIR"
    builtin unset NORI_ZSH_ZDOTDIR
else
    builtin unset ZDOTDIR
fi

{
    # zsh treats unset ZDOTDIR as if it were HOME. We do the same.
    builtin typeset _nori_file="${ZDOTDIR-$HOME}/.zshenv"
    [[ ! -r "$_nori_file" ]] || builtin source -- "$_nori_file"

    if [[ -o interactive \
       && -z "${ZSH_EXECUTION_STRING:-}" \
       && "${NORI_SHELL_INTEGRATION:-1}" != "0" \
       && -n "${NORI_SHELL_INTEGRATION_DIR:-}" \
       && -r "${NORI_SHELL_INTEGRATION_DIR}/nori-zsh-integration.zsh" \
       && "${TERM:-}" == "xterm-256color" \
       && -z "${NORI_ZSH_RESTORE_TERM:-}" ]]; then
        # Keep startup TERM-compatible prompt/theme selection during shell init,
        # then restore the managed xterm-256color identity before the first
        # interactive command executes.
        builtin export NORI_ZSH_RESTORE_TERM="$TERM"
        builtin export TERM="xterm-ghostty"
        builtin typeset -g _NORI_DELAY_TERM_RESTORE_UNTIL_FIRST_PROMPT=1
    fi
} always {
    if [[ -o interactive ]]; then
        # We overwrote GhosttyKit's injected ZDOTDIR, so manually load Ghostty's
        # zsh integration if available.
        #
        # We can't rely on GHOSTTY_ZSH_ZDOTDIR here because Ghostty's own zsh
        # bootstrap unsets it before chaining into this nori wrapper.
        if [[ "${NORI_LOAD_GHOSTTY_ZSH_INTEGRATION:-0}" == "1" ]]; then
            if [[ -n "${NORI_SHELL_INTEGRATION_DIR:-}" ]]; then
                builtin typeset _nori_ghostty="$NORI_SHELL_INTEGRATION_DIR/ghostty-integration.zsh"
            fi
            if [[ ! -r "${_nori_ghostty:-}" && -n "${GHOSTTY_RESOURCES_DIR:-}" ]]; then
                builtin typeset _nori_ghostty="$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
            fi
            [[ -r "$_nori_ghostty" ]] && builtin source -- "$_nori_ghostty"
        fi

        # Load nori integration (unless disabled)
        if [[ "${NORI_SHELL_INTEGRATION:-1}" != "0" && -n "${NORI_SHELL_INTEGRATION_DIR:-}" ]]; then
            builtin typeset _nori_integ="$NORI_SHELL_INTEGRATION_DIR/nori-zsh-integration.zsh"
            [[ -r "$_nori_integ" ]] && builtin source -- "$_nori_integ"
        fi
    fi

    builtin unset _nori_file _nori_ghostty _nori_integ
}
