var FoundationData = artifacts.require("./FoundationData.sol");
var Foundation = artifacts.require("./Foundation.sol");

var adminId = "timgalebach";
var weiToExtend = 0;
var weiToCreate = 0;
var instance;
var oneGwei = 1000000000; //9 zeros
var fiveGwei = 5000000000; //9 zeros
var tenGwei = 10000000000; //10 zeros
var contractGasLimit = 4390000; //4.39M
var fnGasLimit = 1000000; //1.0M

var metamaskAddr = "0x406Dd5315e6B63d6F1bAd0C4ab9Cd8EBA6Bb1bD2";

module.exports = function(deployer, network, accounts) {
    //// for testrpc
    if ( network == "testrpc" ) {
        var user2 = "timg";
        var user3 = "jaredb";
        var account2 = accounts[1];
        var account3 = accounts[2];

        deployer.deploy(FoundationData, adminId, {from: accounts[0]}).then(function() {
            return deployer.deploy(Foundation, FoundationData.address, adminId, weiToExtend, weiToCreate, {from: accounts[0]});
        });
        deployer.then(function() {
            return FoundationData.deployed();
        }).then(function(fdi) {
            instance = fdi;
            return instance.setFoundationContract(Foundation.address);
        }).then(function(tx) {
            return Foundation.deployed();
        }).then(function(fi) {
            instance = fi;
            return instance.createId(user2, {from: account2});
        }).then(function(tx) {
            return instance.createId(user3, {from: account3});
        });
    }

    //deploy from scratch
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
            return Foundation.deployed();
        }).then(function(f) {
            instance = f;
            return instance.addPendingUnification(metamaskAddr, fnData);
        });
    }

    /*
    //when FoundationData is already deployed
    if ( network == "ropsten" ) {
        var foundationDataContract = "0x38b4939013b9d299a78e7cd4fc7de58c48e4b261";
        var contractData =  {from: accounts[0],
                             gas: contractGasLimit,
                             gasPrice: fiveGwei};
        var fnData = {from: accounts[0],
                      gas: fnGasLimit,
                      gasPrice: fiveGwei};

        deployer.deploy(Foundation, foundationDataContract, adminId,
                        weiToExtend, weiToCreate, contractData).then(function() {
                           return FoundationData.at(foundationDataContract);
        }).then(function(fdi) {
            instance = fdi;
            return instance.setFoundationContract(Foundation.address, fnData);
        });
    }
*/

};
