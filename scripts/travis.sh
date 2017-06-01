#!/usr/bin/env bash

# install stack
nix-env -i stack

# install cabal2nix 2.2.1
CABAL2NIX_DIR=$(mktemp -d)
git clone https://github.com/NixOS/cabal2nix "$CABAL2NIX_DIR"
pushd "$CABAL2NIX_DIR"
git checkout b6834fd420e0223d0d57f8f98caeeb6ac088be88
PATH="$HOME/.local/bin:$PATH"
stack setup
stack init
stack build
stack install
popd
which cabal2nix
cabal2nix --version

# run stack2nix tests
stack setup
stack test