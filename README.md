truffle test --network testrpc test/foundation-testrpc.js 
<p>testrpc -p 8546</p>

** To run on Ropsten
*geth --testnet --rpc

**FoundationData Ropsten
0x867ef1f9e431394e05be46df1df06ba73e85fa93
**Foundation Ropsten
0x3d38a834d911157cc1f1306273a9d790aa2b2c51

**Deployment Steps
1. Deploy FoundationData
2. Deploy Foundation, passing address of FoundationData
3. call setFoundationContract in FoundationData with address from step 2
