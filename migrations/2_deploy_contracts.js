var FoundationData = artifacts.require("./FoundationData.sol");
var Foundation = artifacts.require("./Foundation.sol");

var foundationDataAddr = "0xba6602e73a33e41ea4c4ed5bc24c7e2303090610";
var adminId = "timgalebach";
var weiToExtend = 0;
var weiToCreate = 0;
var instance;
var oneGwei = 1000000000; //9 zeros
var fiveGwei = 5000000000; //9 zeros
var tenGwei = 10000000000; //10 zeros
var contractGasLimit = 4390000; //4.39M
var fnGasLimit = 1000000; //1.0M

module.exports = function(deployer, network, accounts) {
    //// for testrpc
    if ( network == "testrpc" ) {
        deployer.deploy(FoundationData, adminId, {from: accounts[0]}).then(function() {
            return deployer.deploy(Foundation, FoundationData.address, adminId, weiToExtend, weiToCreate, {from: accounts[0]});
        });
        deployer.then(function() {
            return FoundationData.deployed();
        }).then(function(fdi) {
            instance = fdi;
            return instance.setFoundationContract(Foundation.address);
        }).then(function(tx) {
            return instance.getFoundationContract.call();
        }).then(function(v) {
            console.log(v.valueOf());
        });
    }

    if ( network == "ropsten" ) {
        var contractData =  {from: accounts[0],
                             gas: contractGasLimit,
                             gasPrice: fiveGwei};
        var fnData = {from: accounts[0],
                      gas: fnGasLimit,
                      gasPrice: fiveGwei};

        deployer.deploy(FoundationData, adminId, contractData).then(function() {
            return deployer.deploy(Foundation, FoundationData.address, adminId,
                                   weiToExtend, weiToCreate, contractData);
        });
        deployer.then(function() {
            return FoundationData.deployed();
        }).then(function(fdi) {
            instance = fdi;
            return instance.setFoundationContract(Foundation.address, fnData);
        }).then(function(tx) {
            return instance.getFoundationContract.call();
        }).then(function(v) {
            console.log(v.valueOf());
        });
    }
};
