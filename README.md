truffle test --network testrpc test/foundation-testrpc.js 
<p>testrpc -p 8546</p>

** To run on Ropsten
*geth --testnet --rpc

**FoundationData Ropsten
0xb96e32c8ec5771a8a86256223e110af15c0e2548
**Foundation Ropsten
0x9d28db2bbee5a0a3700ff297b5d2b67b5c7e4314

**Deployment Steps
1. Deploy FoundationData
2. Deploy Foundation, passing address of FoundationData
3. call setFoundationContract in FoundationData with address from step 2
