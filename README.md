truffle test --network testrpc test/foundation-testrpc.js 
<p>testrpc -p 8546</p>

** To run on Ropsten
*geth --testnet --rpc

**FoundationData Ropsten
0x38b4939013b9d299a78e7cd4fc7de58c48e4b261
**Foundation Ropsten
0x334c1e331ffca04b1aa902347994ddcb42e84858

**Deployment Steps
1. Deploy FoundationData
2. Deploy Foundation, passing address of FoundationData
3. call setFoundationContract in FoundationData with address from step 2
