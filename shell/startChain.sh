#!/usr/bin/env bash

geth --datadir ./localchain/chaindata --networkid 2017 --rpc --rpcaddr 127.0.0.1 --rpcport 8545 --rpccorsdomain "http://localhost:3000"
