var Harmony = artifacts.require("./Harmony.sol");

contract('Harmony', function(accounts) {
    var account1 = accounts[0];
    var account2 = accounts[1];
    var account3 = accounts[2];
    var account4 = accounts[3];
    var account5 = accounts[4];
    var account6 = accounts[5];

    var name1 = "timtime";
    var weiToExtend = 5;

    it("create a new id; extend its active period; check that it's unified", function() {
        var ns;
        return Harmony.new(account6, weiToExtend).then(function(instance) {
            u = instance;
            return u.createId(name1, {from: account1});
        }).then(function(tx) {
            return u.extendIdOneYear(name1, {value: weiToExtend})
        }).then(function(tx) {
            return u.harmonizedP.call(account1, name1);
        }).then(function(res) {
            assert.equal(res.valueOf(), true, "masterId and address not linked");
        });
    });

   it("create a new id; extend its active period; check that it's not unified with the wrong account", function() {
        var ns;
        return Harmony.new(account6, weiToExtend).then(function(instance) {
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
            return u.addPendingHarmonization(name1, account2, {from: account1});
        }).then(function(tx) {
            return u.confirmPendingHarmonization(name1, {from: account2});
        }).then(function(tx) {
            return u.resolveToName.call(account1);
        }).then(function(res) {
            assert.equal(res.valueOf(), name1, "account1 doesn't resolve to name");
            return u.resolveToName.call(account2);
        }).then(function(res) {
            assert.equal(res.valueOf(), name1, "account2 doesn't resolve to name");
        });
    });
});


/* tests:
 - too low wei doesn't extend, throws
 - expired names throw
*/
