#!/bin/bash

###
# install tools
###

# Liquid Prompt
mkdir -p ~/.liquidprompt
curl -o ~/.liquidprompt/liquidprompt https://github.com/liquidprompt/liquidprompt/releases/download/v2.2.1/liquidprompt
# Only load Liquid Prompt in interactive shells, not from a script or from scp
[[ $- = *i* ]] && source ~/.liquidprompt/liquidprompt

###
# Enable tools and set up aliases
###

echo "\n\nShell extras from adamnfish/dotfiles\n\n" >> ~/.bash_aliases
cat shell_extras.sh >> ~/.bash_aliases
