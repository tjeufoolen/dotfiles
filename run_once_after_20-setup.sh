#!/bin/bash
# SDKMAN
[ -d "$HOME/.sdkman" ] || curl -s "https://get.sdkman.io" | bash

# Node LTS
eval "$(fnm env --shell bash)"
fnm install --lts && fnm default lts-latest
