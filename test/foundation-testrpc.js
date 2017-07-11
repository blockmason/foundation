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

    it("checks that two addresses are linked to the same id", function() {
        var ns;
        return Foundation.new(account6, weiToExtend).then(function(instance) {
            u = instance;
            return u.createId(name2, {from: account1, value: weiToExtend});
        }).then(function(tx) {
            return u.addPendingUnification(name2, account2, {from: account1});
        }).then(function(tx) {
            return u.confirmPendingUnification(name2, {from: account2});
        }).then(function(tx) {
            return u.areSameId.call(account1, account2);
        }).then(function(res) {
            assert.equal(res.valueOf(), true, "account1 and account2 aren't added to id");
        });
    });

    it("creates an id, adds address and returns all addresses", function() {
        var ns;
        return Foundation.new(account6, weiToExtend).then(function(instance) {
            u = instance;
            return u.createId(name2, {from: account1, value: weiToExtend});
        }).then(function(tx) {
            return u.addPendingUnification(name2, account2, {from: account1});
        }).then(function(tx) {
            return u.confirmPendingUnification(name2, {from: account2});
        }).then(function(tx) {
            return u.addPendingUnification(name2, account3, {from: account2});
        }).then(function(tx) {
            return u.confirmPendingUnification(name2, {from: account3});
        }).then(function(tx) {
            return u.addPendingUnification(name2, account4, {from: account3});
        }).then(function(tx) {
            return u.confirmPendingUnification(name2, {from: account4});
        }).then(function(tx) {
            return u.addPendingUnification(name2, account5, {from: account4});
        }).then(function(tx) {
            return u.confirmPendingUnification(name2, {from: account5});
        }).then(function(tx) {
            return u.addPendingUnification(name2, account6, {from: account5});
        }).then(function(tx) {
            return u.confirmPendingUnification(name2, {from: account6});
        }).then(function(tx) {
            return u.resolveToAddresses.call(name2);
        }).then(function(addresses) {
//            console.log(addresses);
            assert.equal(addresses[0], account1, "index 0 does not equal " + account1);
            assert.equal(addresses[1], account2, "index 1 does not equal " + account2);
            assert.equal(addresses[2], account3, "index 2 does not equal " + account3);
            assert.equal(addresses[3], account4, "index 3 does not equal " + account4);
            assert.equal(addresses[4], account5, "index 4 does not equal " + account5);
            assert.equal(addresses[5], account6, "index 5 does not equal " + account6);

        });
    });

    it("adds and deletes an address", function() {
        var ns;
        return Foundation.new(account6, weiToExtend).then(function(instance) {
            u = instance;
            return u.createId(name2, {from: account1, value: weiToExtend});
        }).then(function(tx) {
            return u.addPendingUnification(name2, account2, {from: account1});
        }).then(function(tx) {
            return u.confirmPendingUnification(name2, {from: account2});
        }).then(function(tx) {
             return u.resolveToAddresses.call(name2);
        }).then(function(addresses) {
//            console.log(addresses);
            assert.equal(addresses[1], account2, "account2 not added");
            return u.deleteAddr(account2);
        }).then(function(tx) {
           return u.resolveToAddresses.call(name2);
        }).then(function(addresses) {
            //console.log(addresses);
            assert.equal(addresses[1], 0, "account2 not deleted successfully");
        });
    });

    it("tries to delete address when only 1 address exists", function() {
        var ns;
        return Foundation.new(account6, weiToExtend).then(function(instance) {
            u = instance;
            return u.createId(name2, {from: account1, value: weiToExtend});
        }).then(function(tx) {
            return u.resolveToAddresses.call(name2);
        }).then(function(addresses) {
  //          console.log(addresses);
            return u.deleteAddr(account1);
        }).catch(function(error) {
//            console.log(account1);
            assert.equal(error.toString(), "Error: VM Exception while processing transaction: invalid opcode", "Problem while deleting last remaining address");
        });
    });

});


/* tests:
 - too low wei doesn't extend, throws
 - expired names throw
*/
