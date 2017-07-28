truffle test --network testrpc test/foundation-testrpc.js 
<p>testrpc -p 8546</p>

** To run on Ropsten
*geth --testnet --rpc

**FoundationData Ropsten
0xba6602e73a33e41ea4c4ed5bc24c7e2303090610
**Foundation Ropsten
0x94bee2ff9e62343f82f4465eee54d0d3540bb7f4

**Deployment Steps
1. Deploy FoundationData
2. Deploy Foundation, passing address of FoundationData
3. call setFoundationContract in FoundationData with address from step 2
