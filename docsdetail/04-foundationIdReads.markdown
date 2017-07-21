## Getting Info About FoundationIds
The most common and useful functions that developers will be interested in with regards to FoundationIds are the functions to do things such as retrieve the addresses of a FoundationId, retrieve the FoundationId of an address etc.

---
isUnified checks if an address is associated with a foundationId and returns true if it is.
```javascript
function isUnified(address _addr, bytes32 _name) nameActive(_name) constant returns (bool) {}
```
---
areSameId checks if two addresses are contained within the same foundationId
```javascript
function areSameId(address _addr1, address _addr2) public constant returns (bool) {}
```
---
resolveToName returns the foundationId associated with the address if there is one associated, otherwise it will throw.
```javascript
function resolveToName(address _addr) public nameExists(addrToName[_addr]) nameActive(addrToName[_addr]) constant returns (bytes32) {}
```
---
getAddrIndex returns the address at the index requested from the user's foundationId.  See the section on getting addresses for more info.
```javascript
function getAddrIndex(bytes32 _name, uint index) public nameExists(_name) nameActive(_name) constant returns (address) {}
```
---
getAddrLength gets the length of the array of addresses for a foundationId.  See the section on getting addresses for more info.
```javascript
function getAddrLength(bytes32 _name) public nameExists(_name) nameActive(_name) constant returns (uint) {}
```
---
hasName checks if an address has a foundationId.  Returns true of false.
```javascript
function hasName(address _addr) public constant returns (bool) {}
```
