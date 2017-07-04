pragma solidity ^0.4.11;

/**
@title Foundation
@author Timothy Galebach, Jared Bowie
@dev An ID that unifies a single users multiple addresses on the Ethereum blockchain.
*/

contract Foundation {

  bytes32 admin; //the master id associated with the admin
  uint weiToExtend; //amount of eth needed to extend a year
  uint adminBalanceWei;
  uint8 maxNumToDeactivateAddr;
  uint extensionPeriod = 60*60*24*365;

  struct FoundationId {
    bool initialized;
    address[] ownedAddresses;
    address pendingOwned; //an address requiring confirmation to add to owned
    uint activeUntil; //the date/time when this id deactivates
    uint depositBalanceWei; //how much deposit this owner has
    bytes32 name;
    uint8 numToDeactivateAddr; //how many addresses needed to deactivate address
    mapping ( address => bool ) activeAddr;
    //requests to deactivate; goes diswantedAddr => addresses that diswant it
    mapping ( address => address[] ) deactivateReqs;
    address[] addrToDeactivate;
  }

  mapping ( address => bytes32 )  addrToName;
  mapping ( bytes32  => FoundationId ) nameToId;

  /**
	@notice Checks whether a name is active according to it's activeUntil parameter.
	@param _name The name of the ID
  */


  modifier nameActive(bytes32 _name) {
    if ( nameToId[_name].activeUntil < now ) throw;
    _;
  }

  /**
	@notice Checks if a name is associated with an address, if already associated throws.
	@param _name The name of the ID.
	@param _addr The address to check.
  */

  modifier isNewNameAddrPair(bytes32 _name, address _addr) {
    if ( idEq(_name, addrToName[_addr]) ) throw; //throw error if pair exists
    _;
  }



  modifier isNewName(bytes32 _name) {
    if ( nameToId[_name].initialized ) throw;
    _;
  }

  /**
	@notice Checks if a name exists to prevent duplicates from being created.
	@param _name The name of the ID
  */

  modifier nameExists(bytes32 _name) {
    if ( ! nameToId[_name].initialized ) throw;
    _;
  }


   /**
	@notice Checks if a name is the owner of the address
	@param _name The name of the ID
  */

  modifier isOwner(bytes32 _name) {
    //msg.sender should be one of the addresses that owns the master id .
    if ( compare(_name, addrToName[msg.sender]) != 0 ) throw;
    if ( !nameToId[_name].activeAddr[msg.sender] ) throw;
    _;
  }

   /**
	@notice Checks if a name is the owner of the address
  */

  modifier isAdmin() {
    if ( compare(addrToName[msg.sender], admin) != 0 ) throw;
    _;
  }

  modifier extender() {
    if ( msg.value != weiToExtend ) throw;
    adminBalanceWei += msg.value;
    _;
  }


   /**
	@notice Creates the contract
	@param _adminName The name of the ID to be the admin ID
	@param _weiToExtend The amount in wei required to extend the validity of a FoundationID for 1 year.

  */

  //initializes contract with msg.sender as the first admin address
  function Foundation(bytes32 _adminName, uint _weiToExtend) {
    admin = _adminName;
    createIdPrivate(_adminName, msg.sender, (2**256 - 1));
    weiToExtend = _weiToExtend;
    maxNumToDeactivateAddr = 1;
  }

   /**
	@notice Checks whether an address is associated with a FoundationID
	@param _addr The address of the to check
	@param _name The name of the FoundationID

  */

  function isUnified(address _addr, bytes32 _name) nameActive(_name) constant returns (bool) {
    return idEq(addrToName[_addr], _name);
  }

   /**
	@notice Get the amount of Wei required to extend a FoundationID for 1 year.

  */

  function alterWeiToExtend(uint _weiToExtend) isAdmin {
    weiToExtend = _weiToExtend;
  }

    /**
	@notice Get the amount of Wei required to extend a FoundationID for 1 year.

  */

  function getWeiToExtend() constant returns (uint weiAmount) {
    return weiToExtend;
  }


   /**
	@notice Extends a FoundationID for 1 year if the exact amount for the fee is sent.
	@param _name the name of the ID to extend.
  */

  //msg.value
  //adds a year to the end of now, if the balance is right
  function extendIdOneYear(bytes32 _name) payable extender nameExists(_name) {
    if ( msg.value != weiToExtend ) throw;
    adminBalanceWei += msg.value;
    nameToId[_name].activeUntil = now + extensionPeriod;
  }

   /**
	@notice Deposit Wei into the FoundationID.  This deposit is then withdrawable by any address associated with that FoundationID
	@param _name the name of the ID to deposit to.
  */

  function depositWei(bytes32 _name) payable isOwner(_name) nameExists(_name) {
    nameToId[_name].depositBalanceWei += msg.value;
  }

   /**
	@notice get the amount of wei on deposit at a given FoundationID
	@param _name the name of the FoundationID.
  */

  function getDepositWei(bytes32 _name) nameExists(_name) constant returns (uint) {
    return nameToId[_name].depositBalanceWei;
  }

   /**
	@notice Change the number of addresses associated with FoundationID required to deactivate another address.
	@param _name the name of the FoundationID.
        @param newNumToD the new number of addresses required to deactivate.
  */

  function alterNumToDeactivate(bytes32 _name, uint8 newNumToD) isOwner(_name) {
    if ( newNumToD < 2 ) throw;
    if ( newNumToD > maxNumToDeactivateAddr ) throw;
    nameToId[_name].numToDeactivateAddr = newNumToD;
  }

  function initNameAddrPair(bytes32 _name, address _addr) private {
    addrToName[_addr] = _name;
  }

   /**
	@dev Start creating a new FoundationID
  */

  function linkAddrToId(bytes32 _name, address _addr) private {
    nameToId[_name].ownedAddresses.push(_addr);
    nameToId[_name].activeAddr[_addr] = true;
  }


   /**
	@notice create a new FoundationID.
        @param _name the name of the new FoundationID
        @param _addr The address of the creator.
  */


  function createIdPrivate(bytes32 _name, address _addr, uint _activeUntil) isNewName(_name) private {
    initNameAddrPair(_name, _addr);
    //initialized in an inactive state
    nameToId[_name].initialized = true;
    nameToId[_name].activeUntil = _activeUntil;
    nameToId[_name].name = _name;
    nameToId[_name].numToDeactivateAddr = 1;
    nameToId[_name].depositBalanceWei = 0;
    linkAddrToId(_name, _addr);
  }

   /**
	@notice create a new FoundationID.
        @param _name the name of the new FoundationID
  */


  function createId(bytes32 _name) extender isNewName(_name) payable {
    uint _activeUntil = now + extensionPeriod;
    createIdPrivate(_name, msg.sender, _activeUntil);
  }

   /**
	@notice Add an address to a FoundationID, must be added from existing address associated with the FoundationID
        @param _name the name of the FoundationID to add the address to.
        @param _addr the new address to add.
  */

  function addPendingUnification(bytes32 _name, address _addr) nameActive(_name) isOwner(_name) isNewNameAddrPair(_name, _addr) {
    nameToId[_name].pendingOwned = _addr;
  }

   /**
	@notice Confirm an address to be added to a FoundationID
        @dev This must be confirmed by the pending address.
        @param _name the name of the FoundationID to add the address to.
  */

  function confirmPendingUnification(bytes32 _name) nameActive(_name) {
    if ( nameToId[_name].pendingOwned != msg.sender ) throw;
    initNameAddrPair(_name, msg.sender);
    linkAddrToId(_name, msg.sender);
    nameToId[_name].pendingOwned = 0;
  }

   /**
	@notice Deactivate an address associated with your FoundationID
        @param _addr the address to deactivate.
  */

  function requestDeactivate(address _addr) nameExists(addrToName[_addr]) isOwner(addrToName[_addr]) {
    FoundationId hi = nameToId[addrToName[_addr]];
    if ( hi.deactivateReqs[_addr].length == 0 ) {
      hi.deactivateReqs[_addr].push(msg.sender);
      hi.addrToDeactivate.push(_addr);
      return;
    }
    if ( member(msg.sender, hi.deactivateReqs[_addr]) ) {
      return;
    }
    if ( hi.deactivateReqs[_addr].length + 1 != hi.numToDeactivateAddr ) {
      hi.deactivateReqs[_addr].push(msg.sender);
      hi.addrToDeactivate.push(_addr);
      return;
    }
    //otherwise, we need to deactivate and delete all deactivation requests
    hi.activeAddr[_addr] = false;
    for (uint i=0; i < hi.addrToDeactivate.length; i++) {
      hi.deactivateReqs[hi.addrToDeactivate[i]].length = 0;
    }
    hi.addrToDeactivate.length = 0;
  }

   /**
	@notice Return the FoundationID that is associated with the address.
        @param _addr the address to lookup
        @return The FoundationID
  */

  function resolveToName(address _addr) nameExists(addrToName[_addr]) nameActive(addrToName[_addr]) constant returns (bytes32) {
    return addrToName[_addr];
  }

   /**
	@notice Returns an array of addresses associated with a FoundationID
        @param _name The name of the FoundationID to lookup
        @return an array of addresses associated with the FoundationID
  */

  function resolveToAddresses(bytes32 _name) nameExists(_name) nameActive(_name) constant returns (address[]) {
    return nameToId[_name].ownedAddresses;
  }

   /**
	@notice allows the admin of the contract with withdraw ethereum received through FoundationID extension payments.
        @param amount the amount to withdraw in wei
        @return success if operation was successful or not
  */

  function withdraw(uint amount) isAdmin returns (bool success) {
    if ( adminBalanceWei < amount ) throw;
    adminBalanceWei -= amount;
    return msg.sender.send(amount);
  }

   /**
	@notice allows owner of FoundationID to withdraw ethereum from their deposited amount
        @param _name The FoundationID name
        @param amount The amount in wei to withdraw
        @return success if operation was successful or not
  */

  function withdrawDeposit(bytes32 _name, uint amount) isOwner(_name) returns (bool success) {
    if ( nameToId[_name].depositBalanceWei < amount ) throw;
    nameToId[_name].depositBalanceWei -= amount;
    return msg.sender.send(amount);
  }

  //////////////////////////////////
  /////  helpers
  /////////////////////////////////
  function compare(bytes32 a, bytes32 b) private constant returns (int) {
    //    bytes memory a = bytes(_a);
    //    bytes memory b = bytes(_b);
    uint minLength = a.length;
    if (b.length < minLength) minLength = b.length;
    for (uint i = 0; i < minLength; i ++)
      if (a[i] < b[i])
        return -1;
      else if (a[i] > b[i])
        return 1;
    if (a.length < b.length)
      return -1;
    else if (a.length > b.length)
      return 1;
    else
      return 0;
  }

  function member(address e, address[] l) constant returns(bool) {
    for ( uint i=0; i<l.length; i++ ) {
      if ( l[i] == e ) return true;
    }
    return false;
  }

  function idEq(bytes32 _id1, bytes32 _id2) constant returns (bool) {
    return ( compare(_id1, _id2) == 0 );
  }
}
