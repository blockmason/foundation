## Getting Addresses of FoundationsIds
Due to current limitations of the Ethereum Virtual Machine retrieving a list of addresses associated with a FoundationId is not as simple and straightforward as you might expect.

Dynamic arrays cannot be retrived from external contracts currently.  The address array for FoundationIds is dynamic.  So let's go over a quick and easy pattern for getting all the addresses associated with a foundationId.

### Create an ABI for Foundation in Your Contract
For our example we'll create a simple ABI with the functions from Foundation that we'll be using.
```javascript
contract Foundation {
  function resolveToName(address _addr) constant returns (bytes32) {}
  function getAddrLength(bytes32 _name) constant returns (uint) {}
  function getAddrIndex(bytes32 _name, uint index) constant returns (address) {}
  function hasName(address _addr) constant returns (bool) {}
}
```
Next I like to create some local functions to call on the ABI just to simplify everything.  These functions are just shortcuts to the Foundation functions.
```javascript
  function getAddrIndex(bytes32 foundId, uint index) constant returns (address) {
    Foundation f = Foundation(foundationAddress);
    return f.getAddrIndex(foundId, index);
  }

  function getAddrLength(bytes32 foundId) constant returns (uint) {
    Foundation f = Foundation(foundationAddress);
    uint addrLength = f.getAddrLength(foundId);
    return addrLength;
  }

  function getFoundId(address _addr) constant returns (bytes32) {
    Foundation f = Foundation(foundationAddress);
    bytes32 foundId = f.resolveToName(_addr);
    return foundId;
  }

  function hasFName(address _addr) constant returns (bool) {
    Foundation f = Foundation(foundationAddress);
    bool hasF = f.hasName(_addr);
    return hasF;
  }
```
### Get All Addresses
Finally we'll create our function to get all the addresses of a foundationId.
```javascript
  address[] allAddr;
  function getFoundAddresses(bytes32 foundId) constant returns (address[]) {
    Foundation f = Foundation(foundationAddress);
    uint addrLength = f.getAddrLength(foundId);
    for (uint i=0; i < addrLength; i++) {
      allAddr.push(getAddrIndex(foundId, i));
    }
    return allAddr;
  }
```
Essentially what we're doing here is getting the length of the FoundationId's array, then looping through and asking for the address at each index number.  In previous functions you may have already also checked whether the foundationId does in fact exist or looked up the foundationId for an adddress.
We anticipate in the future being able to return dynamic arrays from external functions which will greatly simplify this process.  
