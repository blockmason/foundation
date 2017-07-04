var Harmony = artifacts.require("./Harmony.sol");

contract('Harmony', function(accounts) {
    //accounts are geth testnet accounts
    var zeroWeiHarmony = "0xa9afc0903c7e7f09125dd52e9a1301fc3f2244b5";
    var account1 = "0x589e416768121aa9c5efad6f9f7f6f8e697d44bb";
    var account2 = accounts[1];
    var account3 = accounts[2];

    var name1 = "timtime2";
    var weiToExtend = 0;

    it("create a new id; extend its active period; check that it's unified", function() {
        var h;
        Harmony.at(zeroWeiHarmony).then(function(instance) {
            h = instance;
            console.log(instance);
        });
            /*            return h.createId(name1, {from: account1});
        }).then(function(tx) {
            return h.extendIdOneYear(name1, {value: weiToExtend})
        }).then(function(tx) {
            return h.harmonizedP.call(account1, name1);
        }).then(function(res) {
            assert.equal(res.valueOf(), true, "masterId and address not linked");
        });
    });
*/
    /*
   it("create a new id; extend its active period; check that it's not unified with the wrong account", function() {
        var ns;
        return Harmony.new(account1, weiToExtend).then(function(instance) {
            u = instance;
            return u.createId(name1, {from: account1});
        }).then(function(tx) {
            return u.extendIdOneYear(name1, {value: weiToExtend})
        }).then(function(tx) {
            return u.harmonizedP.call(account2, name1);
        }).then(function(res) {
            assert.equal(res.valueOf(), false, "masterId and address shouldn't be linked");
        });
   });

    it("check that an id resolves to both its addresses", function() {
        var ns;
        return Harmony.new(account6, weiToExtend).then(function(instance) {
            u = instance;
            return u.createId(name1, {from: account1});
        }).then(function(tx) {
            return u.extendIdOneYear(name1, {value: weiToExtend})
        }).then(function(tx) {
            return u.harmonizeAddr(name1, {from: account2});
        }).then(function(tx) {
            return u.resolveToName.call(account1);
        }).then(function(res) {
            assert.equal(res.valueOf(), name1, "Address doesn't resolve to name");
            return u.resolveToName.call(account2);
        }).then(function(res) {
            assert.equal(res.valueOf(), name1, "Address doesn't resolve to name");
        });
    });
*/
});


/* tests:
 - too low wei doesn't extend, throws
 - expired names throw
*/
