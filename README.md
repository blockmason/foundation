truffle test --network testrpc test/foundation-testrpc.js 
<p>testrpc -p 8546</p>

** To run on Ropsten
*geth --testnet --rpc

**FoundationData Ropsten
0x867ef1f9e431394e05be46df1df06ba73e85fa93
**Foundation Ropsten
0x406b716b01ab7c0acc75ceb9fadcc48ce39f5550

**Deployment Steps
1. Deploy FoundationData
2. Deploy Foundation, passing address of FoundationData
3. call setFoundationContract in FoundationData with address from step 2
