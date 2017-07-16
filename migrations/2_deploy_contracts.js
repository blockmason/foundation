var Foundation = artifacts.require("./Foundation.sol");

module.exports = function(deployer, network, accounts) {
    var admin = "foundadmin";
    var weiToExtend = 0;
    var weiToCreate =0;
    var account1 = accounts[0];
    var account2 = accounts[1];
    var account3 = accounts[2];
    var account4 = accounts[3];
    var user2 = "timg";
    var user3 = "jaredb";

    var h;

    deployer.deploy(Foundation, admin, weiToExtend, weiToCreate, {from: account1});
    deployer.then(function() {
        return Foundation.deployed();
    }).then(function(instance) {
        h = instance;
        return h.extendIdOneYear(admin, {value: weiToExtend});
    }).then(function(tx) {
        return h.createId(user2, {from: account2});
    }).then(function(tx) {
        return h.createId(user3, {from: account3});
    }).then(function(tx) {
        return h.addPendingUnification(user3, account4, {from: account3});
    }).then(function(tx) {
        return h.confirmPendingUnification(user3, {from: account4});
    }).then(function(tx) {
        return h.extendIdOneYear(user2, {value: weiToExtend});
    }).then(function(tx) {
        return h.extendIdOneYear(user3, {value: weiToExtend});
    });
};
