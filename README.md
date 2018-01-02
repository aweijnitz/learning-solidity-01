# Learning Solidity Development - Creating a local private Ethereum testnet

This project is about setting up a local private testnet based on [geth](https://geth.ethereum.org/).

It shows how to 

- Create local test network based on a genesis configuration
- Using the Javascript console to interact with the chain
- Create Ethereum blockchain accounts
- Mine Ether to given accounts, both from command line and using the console
- Create transactions to transfer Ether between accounts

The information in this repo is based on the official geth documentation in [Operating a Private Network](https://github.com/ethereum/go-ethereum#operating-a-private-network)
and the tutorial from [Hackernoon](https://hackernoon.com/heres-how-i-built-a-private-blockchain-network-and-you-can-too-62ca7db556c0).

For basic smart contract development, see [learning-solidity-0](https://github.com/aweijnitz/learning-solidity-0).

## For the impatient

No need to understand anything, just run these commands

    chmod +x ./shell/*sh
    ./shell/installGethMacOSX.sh
    ./shell/initAndStartLocalChain.sh


Now you have a locally running node. See [genesis.json](localchain/genesis.json) for the config details, including 
three initial test accounts with balances.

**Check the node is responding on JSON-RPC**
The node listens for JSON-RPC calls at [http://127.0.0.1:8545](http://127.0.0.1:8545)

You can use __curl__ to connect to it and run calls to the chain. A full list of methods is available in the [JSON-RPC documentation](https://github.com/ethereum/wiki/wiki/JSON-RPC#json-rpc-methods).

    curl -H "Content-Type: application/json" -X POST --data '{"jsonrpc":"2.0","method":"net_version","params":"[]","id":"67"}' 127.0.0.1:8545

**Connect and open interactive console to local network**

    geth attach localchain/chaindata/geth.ipc
    Welcome to the Geth JavaScript console!
    
    instance: Geth/v1.7.3-stable/darwin-amd64/go1.9.2
     modules: admin:1.0 debug:1.0 eth:1.0 miner:1.0 net:1.0 personal:1.0 rpc:1.0 txpool:1.0 web3:1.0
    
    > eth.getBalance("0x0000000000000000000000000000000000000001")
    111111111
    > ^D
    

See the shell scripts in [shell](shell) for details.

## Basic Geth usage

### Mining some initial Ether to a test account

The [genesis configuration](localchain/genesis.json) includes three accounts. This is how you can top up ETH to a given account.
     
    geth --datadir localchain/chaindata/ --mine --minerthreads=1 --etherbase=0x0000000000000000000000000000000000000003

### Adding accounts and adding balance

In order to add new accounts to the chain, just connect to the interactive console (see above) and 
create a new account. Note: These are regular accounts (Externally Owned Accounts, EOA:S), not Smart Contracts.

```javascript

// Create two new accounts
//
account0 = personal.newAccount();       // Asks for pass phrase and returns the new account number
account1 = personal.newAccount()
eth.getBalance(account0);               // Prints '0', since new accounts have no ETH

// Mine some Ether to the new account
//
personal.unlockAccount(account0);
miner.setEtherbase(account0);
miner.start();                          // Let run for a few seconds. Check the output of the node to see blocks coming through
miner.stop();
eth.getBalance(account0);               // Prints something like '35000000000000000000', since we mined ETH to account

// Transfer Ether between accounts
personal.unlockAccount(account0);
transactionId = eth.sendTransaction({ from: account0, to: account1, value: 100 }); // Omitting callback makes the call synchronous
miner.start(); // Need to mine, in order to commit transaction to the blockchain.
miner.stop(); // After a few seconds
eth.getBalance(account1); // --> Returns 100

eth.getTransaction(transactionId); // --> Prints transaction info from the blockchain
```

Read the [full Javascript doc](https://github.com/ethereum/wiki/wiki/JavaScript-API) for details.


## Step-by-Step instructions

Read this for some additional details on what is going on in the scripts.

### Geth installation on MacOSX

Follow the instructions below, or just run the script ```./shell/installGethMacOSX.sh```.

    brew tap ethereum/ethereum
    brew install ethereum

### Setting up a private Ethereum test net based on geth

#### Create folder for config and chain data

    mkdir -p YOURPATH/chaindata

#### Create genesis block config

This is a minimal configuration. See [genesis.json](localchain/genesis.json) for more options.

Save it to ___YOURPATH/myGenesisConf.json___

    {
        "config": {  
            "chainId": 2017, 
            "homesteadBlock": 0,
            "eip155Block": 0,
            "eip158Block": 0
        },
        "difficulty": "0x200",
        "gasLimit": "0x8000000",
        "alloc": {}
    }


#### Initialize the chain, using the genesis block configuration

Assuming you are in the folder where you created the root folder YOURPATH (replace YOURPATH with an actual path of course).

    geth init YOURPATH/myGenesisConf.json --datadir YOURPATH/chaindata

It should output something looking like this

    WARN [12-30|23:57:01] No etherbase set and no accounts found as default
    INFO [12-30|23:57:01] Allocated cache and file handles         database=YOURPATH/chaindata/geth/chaindata cache=16 handles=16
    INFO [12-30|23:57:01] Writing custom genesis block
    INFO [12-30|23:57:01] Successfully wrote genesis state         database=chaindata                                            hash=d1a12d…4c8725
    INFO [12-30|23:57:01] Allocated cache and file handles         database=YOURPATH/chaindata/geth/lightchaindata cache=16 handles=16
    INFO [12-30|23:57:01] Writing custom genesis block
    INFO [12-30|23:57:01] Successfully wrote genesis state         database=lightchaindata                                            hash=d1a12d…4c8725


### Start the private network

    geth --datadir ./YOURPATH/chaindata --networkid 2017

**IMPORTANT!** 
The network id should to be something unique, not be be mixed up with the public running chains.

These are reserved network id:s that you should avoid:

- **0**: Olympic, Ethereum public pre-release testnet
- **1**: Frontier, Homestead, Metropolis, the Ethereum public main network
- **1**: Classic, the (un)forked public Ethereum Classic main network, chain ID 61
- **1**: Expanse, an alternative Ethereum implementation, chain ID 2
- **2**: Morden, the public Ethereum testnet, now Ethereum Classic testnet
- **3**: Ropsten, the public cross-client Ethereum testnet
- **4**: Rinkeby, the public Geth Ethereum testnet
- **42**: Kovan, the public Parity Ethereum testnet
- **7762959**: Musicoin, the music blockchain

### Create first account 

This step creates a personal account, also called Eternally Owned Account (EOA). Not to be confused with a smart contract account.

Keep the network running (previous step) and attach to it from another command line session.
This opens the Javascript console and one can interact with the chain.


    geth attach YOURPATH/chaindata/geth.ipc

Create an account (take note of the passphrase and the account address of course).

    > personal.newAccount()
    Passphrase:
    Repeat passphrase:
    "0x2d2f78a0999ae4efa3c999c35f28b3412673da5d"
    

### Mine initial ETH into the account

The only way to get Ether into an account is through mining, or receiving it through a transaction.
Since we just created the only existing account on the chain, mining is the only option.

Using the Javascript console session started in the previous step

    > miner.start()
    null
    
Checking the output of the running chain, we should see mining beginning

    INFO [12-31|00:38:13] Updated mining threads                   threads=0
    INFO [12-31|00:38:13] Transaction pool price threshold updated price=18000000000
    INFO [12-31|00:38:13] Starting mining operation
    INFO [12-31|00:38:13] Commit new mining work                   number=1 txs=0 uncles=0 elapsed=185.155µs
    INFO [12-31|00:38:16] Generating DAG in progress               epoch=0 percentage=0 elapsed=2.060s
    INFO [12-31|00:38:18] Generating DAG in progress               epoch=0 percentage=1 elapsed=3.828s
    INFO [12-31|00:38:20] Generating DAG in progress               epoch=0 percentage=2 elapsed=5.659s
    INFO [12-31|00:38:22] Generating DAG in progress               epoch=0 percentage=3 elapsed=7.407s
    
Keep it going until you get some Ether on the account.

    > eth.getBalance("0x2d2f78a0999ae4efa3c999c35f28b3412673da5d")
    70000000000000000000

Stop the miner

    > miner.stop()
    true
    
## Links

- [Geth](https://geth.ethereum.org/)
- [JSON-RPC documentation](https://github.com/ethereum/wiki/wiki/JSON-RPC#json-rpc-methods)
- [Ganache](http://truffleframework.com/ganache/) is a prepackaged personal blockchain for development (I opted not to use this, since I believe in learning the basics first)