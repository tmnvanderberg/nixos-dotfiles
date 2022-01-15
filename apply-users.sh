#!/bin/sh
pushd ~/.dotfiles
home-manager switch -f ./users/tmn/home.nix
popd
