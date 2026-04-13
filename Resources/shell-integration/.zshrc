# vim:ft=zsh
#
# Compatibility shim: with the current integration model, nori restores
# ZDOTDIR in .zshenv so this file should never be reached. If it is, restore
# ZDOTDIR and behave like vanilla zsh by sourcing the user's .zshrc.

if [[ -n "${GHOSTTY_ZSH_ZDOTDIR+X}" ]]; then
    builtin export ZDOTDIR="$GHOSTTY_ZSH_ZDOTDIR"
    builtin unset GHOSTTY_ZSH_ZDOTDIR
elif [[ -n "${NORI_ZSH_ZDOTDIR+X}" ]]; then
    builtin export ZDOTDIR="$NORI_ZSH_ZDOTDIR"
    builtin unset NORI_ZSH_ZDOTDIR
else
    builtin unset ZDOTDIR
fi

builtin typeset _nori_file="${ZDOTDIR-$HOME}/.zshrc"
[[ ! -r "$_nori_file" ]] || builtin source -- "$_nori_file"
builtin unset _nori_file
