#!/bin/bash

###
# install tools
###

if command -v apt-get &>/dev/null; then
  apt-get update -q
  DEBIAN_FRONTEND=noninteractive apt-get install -y -q --no-install-recommends liquidprompt emacs-nox

  cp -r .emacs.d ~/
else
  printf "Warning: apt-get not available, skipping liquidprompt installation.\n" >&2
fi


###
# Enable tools and set up aliases
###

printf "\n\n# Shell extras from adamnfish/dotfiles\n\n" >> ~/.bash_aliases
cat shell_extras.sh >> ~/.bash_aliases
