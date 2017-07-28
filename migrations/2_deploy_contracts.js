var FoundationData = artifacts.require("./FoundationData.sol");
var Foundation = artifacts.require("./Foundation.sol");

var foundationDataAddr = "0xba6602e73a33e41ea4c4ed5bc24c7e2303090610";
var adminId = "timgalebach";
var user1 = "timg";
var user2 = "jaredb";
var weiToExtend = 0;
var weiToCreate = 0;
var instance;

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
};
