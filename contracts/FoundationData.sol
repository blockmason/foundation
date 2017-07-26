pragma solidity ^0.4.11;

contract FoundationData {

  address foundationContract;

  struct FoundationId {
    bool initialized;
    address[] ownedAddresses;
    address pendingOwned; //an address requiring confirmation to add to owned
    uint activeUntil; //the date/time when this id deactivates
    uint depositBalanceWei; //how much deposit this owner has
    bytes32 name;
    mapping ( address => bool ) activeAddr;
  }

  mapping ( address => bytes32 ) pendings;
  mapping ( address => bytes32 )  addrToName;
  mapping ( bytes32  => FoundationId ) nameToId;

  /*
     @notice modifier to allow only the main Foundation contract to proxy calls
  */

  modifier isFoundation() {
    if(msg.sender != foundationContract) revert();
    _;
  }

  function FoundationData(address _foundationContract) {
    foundationContract = _foundationContract;
  }

  /*  Setters  */
  function setIdInitialized(bytes32 fId, bool init) public isFoundation {
    nameToId[fId].initialized = init;
  }

  function pushIdOwnedAddresses(bytes32 fId, address _addr) public isFoundation {
    nameToId[fId].ownedAddress.push(_addr);
  }

  function setIdPendingOwned(bytes32 fId, address _pendingAddr) public isFoundation {
    nameToId[fId].pendingOwned = _pendingAddr;
  }

  function setIdDepositBalanceWei(bytes32 fId, uint wei) public isFoundation {
    nameToId[fId].depositBalanceWei = wei;
  }

  function setIdActiveUntil(bytes32 fId, unit _activeUntil) public isFoundation {
    nameToId[fId].activeUntil = _activeUntil;
  }

  function setIdName(bytes32 fId, bytes32 val) public isFoundation {
    nameToId[fId].name = val;
  }

  function setIdActiveAddr(bytes32 fId, address _addr, bool val) public isFoundation {
    nameToId[fId].activeAddr[_addr] = val;
  }

  /*   mapping setters   */
  function setPendings(bytes32 _name, address _addr) public isFoundation {
    pendings[_addr] = _name;
  }

  function setAddrToName(bytes32 _name, address _addr) public isFoundation {
    addrToName[_addr] = _name;
  }

  /*  Getters  */
  function idInitialized(bytes32 fId) constant returns (bool) {
    return nameToId[fid].initialized;
  }

  function idOwnedAddresses(bytes32 fId) constant returns (address[]) {
    return nameToId[fid].ownedAddresses;
  }

  function idPendingOwned(bytes32 fId) constant returns (address) {
    return nameToId[fid].pendingOwned;
  }

  function idDepositBalanceWei(bytes32 fId) constant returns (uint) {
    return nameToId[fid].depositBalanceWei;
  }

  function idActiveUntil(bytes32 fId) constant returns (uint timestamp) {
    return nameToId[fid].activeUntil;
  }

  function idIsActiveAddr(bytes32 fId, address _addr) constant returns (bool) {
    return nameToId[fid].activeAddr[_addr];
  }

  function getPending(address _addr) constant returns (bytes32) {
    return pendings[_addr];
  }

  function getAddrToName(address _addr) constant returns (bytes32) {
    return addrToName[_addr];
  }

}
