truffle test --network testrpc test/foundation-testrpc.js 
<p>testrpc -p 8546</p>

** To run on Ropsten
*geth --testnet --rpc

**FoundationData Ropsten
0xba6602e73a33e41ea4c4ed5bc24c7e2303090610
--0x5c98fbbdba76a44475e831cf84202f596da0f007
**Foundation Ropsten
0x74bec563091b06d9f53b8a3237badf73ff81e7c7

**Deployment Steps
1. Deploy FoundationData
2. Deploy Foundation, passing address of FoundationData
3. call setFoundationContract in FoundationData with address from step 2
