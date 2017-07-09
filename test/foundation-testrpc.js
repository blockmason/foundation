var Foundation = artifacts.require("./Foundation.sol");

contract('Foundation', function(accounts) {
    var account1 = accounts[0];
    var account2 = accounts[1];
    var account3 = accounts[2];
    var account4 = accounts[3];
    var account5 = accounts[4];
    var account6 = accounts[5];

    var name1 = "timtime";
    var name2 = "jbyo";
    var weiToExtend = 5;


    it("creates a new instance of Foundation and gets weiToExtend", function() {
        var extend=5000;
        var ns;
        return Foundation.new(account6, extend).then(function(instance) {
            u = instance;
            return u.getWeiToExtend.call()
        }).then(function(wei) {
            assert.equal(wei.toNumber(), extend, extend + " doesn't equal " + wei.toNumber());
        });
    });

    it("create a new id; extend its active period; check that it's unified", function() {
        var ns;
        return Foundation.new(account6, weiToExtend).then(function(instance) {
            u = instance;
            return u.createId(name1, {from: account1, value: weiToExtend})
        }).then(function(tx) {
            return u.extendIdOneYear(name1, {from: account1, value: weiToExtend})
        }).then(function(tx) {
            return u.isUnified.call(account1, name1);
        }).then(function(res) {
            assert.equal(res.valueOf(), true, "masterId and address not linked");
        });
    });




   it("create a new id; extend its active period; check that it's not unified with the wrong account", function() {
        var ns;
        return Foundation.new(account6, weiToExtend).then(function(instance) {
            u = instance;
            return u.createId(name1, {from: account1, value: weiToExtend});
        }).then(function(tx) {
           return u.extendIdOneYear(name1, {value: weiToExtend})
        }).then(function(tx) {
             return u.isUnified.call(account2, name1);
        }).then(function(res) {
            assert.equal(res.valueOf(), false, "masterId and address shouldn't be linked");
        });
   });

    it("check that an id resolves to both its addresses", function() {
        var ns;
        return Foundation.new(account6, weiToExtend).then(function(instance) {
            u = instance;
            return u.createId(name1, {from: account1, value: weiToExtend});
        }).then(function(tx) {
            return u.extendIdOneYear(name1, {value: weiToExtend})
        }).then(function(tx) {
            return u.addPendingUnification(name1, account2, {from: account1});
        }).then(function(tx) {
            return u.confirmPendingUnification(name1, {from: account2});
        }).then(function(tx) {
            return u.resolveToName.call(account1);
        }).then(function(res) {
            assert.equal(web3.toAscii(res).replace(/\u0000/g, ''), name1, "account1 doesn't resolve to name");
            return u.resolveToName.call(account2);
        }).then(function(res) {
            assert.equal(web3.toAscii(res).replace(/\u0000/g, ''), name1, "account2 doesn't resolve to name");
        });
    });
});


/* tests:
 - too low wei doesn't extend, throws
 - expired names throw
*/
