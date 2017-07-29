var Foundation = artifacts.require("./Foundation.sol");
var FoundationData = artifacts.require("./FoundationData.sol");

var b2s = function(bytes) {
    var s = "";
    for(var i=2; i<bytes.length; i+=2) {
        var num = parseInt(bytes.substring(i, i+2), 16);
        if (num == 0) break;
        var char = String.fromCharCode(num);
        s += char;
    }
    return s;

};

contract('Foundation', function(accounts) {
    var name1 = "timtime";
    var name2 = "jbyo";
    var adminId = "timgalebach";
    var weiToExtend = 0;
    var weiToCreate = 0;
    var account1 = accounts[0];
    var account2 = accounts[1];
    var account3 = accounts[2];
    var account4 = accounts[3];
    var account5 = accounts[4];
    var account6 = accounts[5];
    var account7 = accounts[6];
    var foundData;
    var u;

    it("creates a new instance of Foundation and gets weiToExtend", async function() {
        foundData = await FoundationData.new(adminId);
        var ns;
        return Foundation.new(foundData.address, adminId, weiToExtend, weiToCreate).then(function(instance) {
            u = instance;
            return foundData.setFoundationContract(u.address);
        }).then(function(tx) {
            return u.getWeiToExtend.call();
        }).then(function(wei) {
            assert.equal(wei.toNumber(), weiToExtend, weiToExtend + " doesn't equal " + wei.toNumber());
        });
    });


    it("create a new id; extend its active period; check that it's unified", async function() {
        foundData = await FoundationData.new(adminId);
        var ns;
        return Foundation.new(foundData.address, adminId, weiToExtend, weiToCreate).then(function(instance) {
            u = instance;
            return foundData.setFoundationContract(u.address);
        }).then(function(tx) {
            return u.createId(name1, {from: account2, value: weiToCreate});
       }).then(function(tx) {
            return u.extendIdOneYear(name1, {from: account2, value: weiToExtend});
        }).then(function(tx) {
            return u.isUnified.call(account2, name1);
       }).then(function(res) {
           assert.equal(res.valueOf(), true, "masterId and address not linked");
        });
    });



   it("create a new id; extend its active period; check that it's not unified with the wrong account", async function() {
        foundData = await FoundationData.new(adminId);
        var ns;
        return Foundation.new(foundData.address, adminId, weiToExtend, weiToCreate).then(function(instance) {
            u = instance;
            return foundData.setFoundationContract(u.address);
        }).then(function(tx) {
            return u.createId(name1, {from: account2, value: weiToCreate});
        }).then(function(tx) {
            return u.extendIdOneYear(name1, {from: account2, value: weiToExtend})
        }).then(function(tx) {
             return u.isUnified.call(account1, name1);
        }).then(function(res) {
            assert.equal(res.valueOf(), false, "masterId and address shouldn't be linked");
        });
   });

    it("check that an id resolves to both its addresses", async function() {
        foundData = await FoundationData.new(adminId);
        var ns;
        return Foundation.new(foundData.address, adminId, weiToExtend, weiToCreate).then(function(instance) {
            u = instance;
            return foundData.setFoundationContract(u.address);
        }).then(function(tx) {
            return u.createId(name1, {from: account2, value: weiToCreate});
        }).then(function(tx) {
            return u.extendIdOneYear(name1, {from: account2, value: weiToExtend})
        }).then(function(tx) {
            return u.addPendingUnification(account3, {from: account2});
        }).then(function(tx) {
            return u.confirmPendingUnification(name1, {from: account3});
        }).then(function(tx) {
            return u.resolveToName.call(account2);
        }).then(function(res) {
            assert.equal(web3.toAscii(res).replace(/\u0000/g, ''), name1, "account1 doesn't resolve to name");
            return u.resolveToName.call(account3);
        }).then(function(res) {
            assert.equal(web3.toAscii(res).replace(/\u0000/g, ''), name1, "account2 doesn't resolve to name");
        });
    });

    it("checks that two addresses are linked to the same id", async function() {
        foundData = await FoundationData.new(adminId);
        var ns;
        return Foundation.new(foundData.address, adminId, weiToExtend, weiToCreate).then(function(instance) {
            u = instance;
            return foundData.setFoundationContract(u.address);
        }).then(function(tx) {
            return u.createId(name2, {from: account2, value: weiToCreate});
        }).then(function(tx) {
            return u.addPendingUnification(account3, {from: account2});
        }).then(function(tx) {
            return u.confirmPendingUnification(name2, {from: account3});
        }).then(function(tx) {
            return u.areSameId.call(account2, account3);
        }).then(function(res) {
            assert.equal(res.valueOf(), true, "account1 and account2 aren't added to id");
        });
    });

    it("creates an id, adds address and returns all addresses", async function() {
        foundData = await FoundationData.new(adminId);
        var ns;
        return Foundation.new(foundData.address, adminId, weiToExtend, weiToCreate).then(function(instance) {
            u = instance;
            return foundData.setFoundationContract(u.address);
        }).then(function(tx) {
            return u.createId(name2, {from: account2, value: weiToCreate});
        }).then(function(tx) {
            return u.addPendingUnification(account3, {from: account2});
        }).then(function(tx) {
            return u.confirmPendingUnification(name2, {from: account3});
        }).then(function(tx) {
            return u.addPendingUnification(account4, {from: account3});
        }).then(function(tx) {
            return u.confirmPendingUnification(name2, {from: account4});
        }).then(function(tx) {
            return u.addPendingUnification(account5, {from: account4});
        }).then(function(tx) {
            return u.confirmPendingUnification(name2, {from: account5});
        }).then(function(tx) {
            return u.addPendingUnification(account6, {from: account5});
        }).then(function(tx) {
            return u.confirmPendingUnification(name2, {from: account6});
        }).then(function(tx) {
            return u.addPendingUnification(account7, {from: account6});
        }).then(function(tx) {
            return u.confirmPendingUnification(name2, {from: account7});
        }).then(function(tx) {
            return u.resolveToAddresses.call(name2);
        }).then(function(addresses) {
//            console.log(addresses);
            assert.equal(addresses[0], account2, "index 0 does not equal " + account2);
            assert.equal(addresses[1], account3, "index 1 does not equal " + account3);
            assert.equal(addresses[2], account4, "index 2 does not equal " + account4);
            assert.equal(addresses[3], account5, "index 3 does not equal " + account5);
            assert.equal(addresses[4], account6, "index 4 does not equal " + account6);
            assert.equal(addresses[5], account7, "index 5 does not equal " + account7);

        });
    });

    it("adds and deletes an address", async function() {
        foundData = await FoundationData.new(adminId);
        var ns;
        return Foundation.new(foundData.address, adminId, weiToExtend, weiToCreate).then(function(instance) {
            u = instance;
            return foundData.setFoundationContract(u.address);
        }).then(function(tx) {
            return u.createId(name2, {from: account2, value: weiToCreate});
        }).then(function(tx) {
            return u.addPendingUnification(account3, {from: account2});
        }).then(function(tx) {
            return u.confirmPendingUnification(name2, {from: account3});
        }).then(function(tx) {
             return u.resolveToAddresses.call(name2);
        }).then(function(addresses) {
           // console.log(addresses);
            assert.equal(addresses[1], account3, "account3 not added");
            return u.deleteAddr(account3, {from: account2});
        }).then(function(tx) {
           return u.resolveToAddresses.call(name2);
        }).then(function(addresses) {
            //console.log(addresses);
            assert.equal(addresses[1], 0, "account3 not deleted successfully");
        });
    });

    it("tries to delete address when only 1 address exists", async function() {
        foundData = await FoundationData.new(adminId);
        var ns;
        return Foundation.new(foundData.address, adminId, weiToExtend, weiToCreate).then(function(instance) {
            u = instance;
            return foundData.setFoundationContract(u.address);
        }).then(function(tx) {
            return u.createId(name2, {from: account2, value: weiToCreate});
        }).then(function(tx) {
            return u.resolveToAddresses.call(name2);
        }).then(function(addresses) {
            return u.deleteAddr(account2);
        }).catch(function(error) {
//            console.log(account1);
            assert.equal(error.toString(), "Error: VM Exception while processing transaction: invalid opcode", "Problem while deleting last remaining address");
        });
    });

    it("adds addresses and gets correct length", async function() {
        foundData = await FoundationData.new(adminId);
        var ns;
        return Foundation.new(foundData.address, adminId, weiToExtend, weiToCreate).then(function(instance) {
            u = instance;
            return foundData.setFoundationContract(u.address);
        }).then(function(tx) {
            return u.createId(name2, {from: account2, value: weiToCreate});
        }).then(function(tx) {
            return u.addPendingUnification(account3, {from: account2});
        }).then(function(tx) {
            return u.confirmPendingUnification(name2, {from: account3});
        }).then(function(tx) {
            return u.getAddrLength(name2);
        }).then(function(addrlength) {
            assert.equal(addrlength.toNumber(), 2, "not getting proper length");
        });
    });

    it("it successfully gets addr at index", async function() {
        foundData = await FoundationData.new(adminId);
        var ns;
        return Foundation.new(foundData.address, adminId, weiToExtend, weiToCreate).then(function(instance) {
            u = instance;
            return foundData.setFoundationContract(u.address);
        }).then(function(tx) {
            return u.createId(name2, {from: account2, value: weiToCreate});
        }).then(function(tx) {
            return u.addPendingUnification(account3, {from: account2});
        }).then(function(tx) {
            return u.confirmPendingUnification(name2, {from: account3});
        }).then(function(tx) {
            return u.getAddrIndex.call(name2, 1);
        }).then(function(address) {
           assert.equal(address, account3, "addrindex not working");
        });
    });

    it("checks whether an address has a name or not", async function() {
        foundData = await FoundationData.new(adminId);
        var ns;
        return Foundation.new(foundData.address, adminId, weiToExtend, weiToCreate).then(function(instance) {
            u = instance;
            return foundData.setFoundationContract(u.address);
        }).then(function(tx) {
            return u.createId(name2, {from: account2, value: weiToCreate});
        }).then(function(tx) {
            return u.hasName.call(account2);
        }).then(function(hasNameBool) {
            console.log(hasNameBool);
            assert.equal(hasNameBool, true, "returning false when true");
            return u.hasName.call(account3);
        }).then(function(hasNameBool) {
            console.log(hasNameBool);
            assert.equal(hasNameBool, false, "returning true when false");

        });
    });

    it("can't add an address to two ids", async function() {
        var addrs1;
        var addrs2;
        foundData = await FoundationData.new(adminId);
        var ns;
        return Foundation.new(foundData.address, adminId, weiToExtend, weiToCreate).then(function(instance) {
            u = instance;
            return foundData.setFoundationContract(u.address);
        }).then(function(tx) {
            return u.createId(name2, {from: account3, value: weiToCreate});
        }).then(function(tx) {
            return u.addPendingUnification(account2, {from: account3});
        }).then(function(tx) {
            return u.addPendingUnification(account2, {from: account1});
        }).then(function(tx) {
            return u.confirmPendingUnification(name2, {from: account2});
        }).then(function(tx) {
            return u.confirmPendingUnification(name1, {from: account2});
        }).then(function(v) {
            assert.equal(true, false, "Shouldn't be able to confirm 2nd id");
        }).catch(function(error) {
            assert.equal(error.toString(), "Error: VM Exception while processing transaction: invalid opcode", "Shouldn't be able to confirm 2nd id");
        });
    });

 /*   it("deposits and withdraws wei", async function() {
        var addrs1;
        var addrs2;
        var depositAmount;
        var originalBalance;
        var secondBalance;
        var thirdBalance;
        foundData = await FoundationData.new(adminId);
        var ns;
        return Foundation.new(foundData.address, adminId, weiToExtend, weiToCreate).then(function(instance) {
            u = instance;
            return foundData.setFoundationContract(u.address);
        }).then(function(tx) {
            originalBalance = web3.eth.getBalance(account1);
            console.log("1-" + originalBalance.toNumber());
            depositAmount = 1000000000000000000;
            return u.depositWei({from: account1, value: depositAmount});
        }).then(function(tx) {
            secondBalance = web3.eth.getBalance(account1).toNumber();
            console.log("2-" + secondBalance);
            assert(secondBalance+depositAmount < originalBalance, "second balance + deposit amount should be less than originalBalance");
            console.log(web3.eth.getBalance(account1).toNumber());
            return u.getDepositWei(name1);
        }).then(function(balance) {
            assert.equal(depositAmount, balance.toNumber(), "balance and depositamount not equal");
            //web3.eth.getBalance
            return u.withdrawDeposit(depositAmount);
        }).then(function(tx) {
            thirdBalance = web3.eth.getBalance(account1).toNumber();
            assert(thirdBalance > secondBalance, "thirdbalance is not greater than secondbalance");
        });
    });*/

});
