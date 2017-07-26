var Foundation = artifacts.require("./Foundation.sol");
var FoundationData = artifacts.require("./FoundationData.sol");

contract('Foundation', function(accounts) {
    var account1 = accounts[0];
    var account2 = accounts[1];
    var account3 = accounts[2];
    var account4 = accounts[3];
    var account5 = accounts[4];
    var account6 = accounts[5];

    var name1 = "timtime";
    var name2 = "jbyo";
    var weiToExtend = 0;
    var weiToCreate = 0;
    var fDataContract = "0x77c107a57144b3720a415f19ba469fcc5788fe27";

    it("test basic functions", function() {
        var extend=5000;
        var ns;
        return Foundation.at(fDataContract).then(function(u) {
            return u.resolveToAddresses.call("timgalebach");
        }).then(function(r) {
            console.log(r.valueOf());
            assert.equal(r.valueOf(), extend, extend + " doesn't equal " + wei.toNumber());
        });
    });

});
