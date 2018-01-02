#!/usr/bin/env bash
curl -H "Content-Type: application/json" -X POST --data '{"jsonrpc":"2.0","method":"net_version","params":"[]","id":"67"}' 127.0.0.1:8545
