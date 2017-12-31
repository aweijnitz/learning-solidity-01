#!/usr/bin/env bash

echo "-------- Checking Dependencies                  --------"
echo "========================================================"

command -v brew >/dev/null 2>&1 || { echo >&2 "Command brew required, but it's not installed.  Please install Homebrew. Aborting."; exit 1; }

echo "-------- INSTALLING GETH                        --------"
echo "-------- This can take a few minutes            --------"
echo "========================================================"

brew update
brew tap ethereum/ethereum
brew install ethereum

