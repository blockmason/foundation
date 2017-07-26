var FoundationData = artifacts.require("./FoundationData.sol");
var Foundation = artifacts.require("./Foundation.sol");

var foundationDataAddr = "0x5c98fbbdba76a44475e831cf84202f596da0f007";
var adminId = "timgalebach";
var weiToExtend = 0;
var weiToCreate = 0;

module.exports = function(deployer, network, accounts) {
    /*
    deployer.deploy(FoundationData, adminId,
                    {from: accounts[0], gasPrice: 100000000000,
                     gas: 3000000 });
     */
    deployer.deploy(Foundation, foundationDataAddr, adminId,
                    weiToExtend, weiToCreate,
                    {from: accounts[0], gas: 4390000,
                     gasPrice: 10000000000});

    /*
    deployer.deploy(FoundationData, adminId,
                    {from: accounts[0]}).then(function() {
        return deployer.deploy(Foundation, FoundationData.address, adminId,
                               weiToExtend, weiToCreate,
                               {from: accounts[0]});
    });
*/
};
