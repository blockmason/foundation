truffle test --network testrpc test/foundation-testrpc.js 
<p>testrpc -p 8546</p>

** To run on Ropsten
*geth --testnet --rpc

**Deployment Steps
1. Deploy FoundationData
2. Deploy Foundation, passing address of FoundationData
3. call setFoundationContract in FoundationData with address from step 2
