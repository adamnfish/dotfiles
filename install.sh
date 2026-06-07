#!/bin/bash

###
# install tools
###

# Liquid Prompt
if command -v apt-get &>/dev/null; then
  apt-get update -q
  apt-get install -y -q liquidprompt
else
  printf "Warning: apt-get not available, skipping liquidprompt installation.\n" >&2
fi


###
# Enable tools and set up aliases
###

echo "\n\nShell extras from adamnfish/dotfiles\n\n" >> ~/.bash_aliases
cat shell_extras.sh >> ~/.bash_aliases
