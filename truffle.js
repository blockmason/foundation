module.exports = {
  networks: {
    testrpc: {
      host: "localhost",
      port: 8546,
      network_id: "*" // Match any network id
    },
    ropsten: {
      host: "localhost",
      port: 8545,
      network_id: 3
    },
    ropstenNoData: {
      host: "localhost",
      port: 8545,
      network_id: 3
    }
  }
};
