#!/usr/bin/env bash

# Ensure data dir
mkdir -p ./localchain/chaindata

# Initialize chain, based in configuration in the genesis file
geth init ./localchain/genesis.json --datadir ./localchain/chaindata --identity LocalTestNet

# Start a node
geth --datadir ./localchain/chaindata --networkid 2017
