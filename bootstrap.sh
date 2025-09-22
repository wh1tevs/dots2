#!/usr/bin/env bash

pacman -S --needed base-devel git curl \
  zsh zsh-completions \
  networkmanager \


pacman -Sy --needed man tree jq \
  networkmanager greetd greetd-tuigreet \
  xdg-desktop-portal xdg-desktop-portal-wlr
# man tree jq

pacman -S networkmanager

pacman -S greetd greetd-tuigreet

# xdg-desktop-portal xdg-desktop-portal-wlr
# flameshot grim qt6-imageformats

# NEOVIM
pacman -S fd tree-sitter-cli
# lsp
# lua-language-server
