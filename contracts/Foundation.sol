pragma solidity ^0.4.11;

import "./AbstractFoundationData.sol";

/**
@title Foundation
@author Timothy Galebach, Jared Bowie
@dev An ID that unifies a single users multiple addresses on the Ethereum blockchain.
*/

contract Foundation {

  AbstractFoundationData afd;
  bytes32 admin; //the master id associated with the admin
  uint weiToExtend; //amount of eth needed to extend a year
  uint weiToCreate;
  uint adminBalanceWei;
  uint8 maxNumToDeactivateAddr;
  uint extensionPeriod = 60*60*24*365;
  //  uint addrSize=50;

  /**
	@notice Checks whether a name is active according to it's activeUntil parameter.
	@param _name The name of the ID
  */
  modifier nameActive(bytes32 _name) {
    if ( afd.idActiveUntil(_name) < now ) revert();
    _;
  }

  /**
	@notice Checks if this address is already in this name.
	@param _name The name of the ID.
	@param _addr The address to check.
  */
  modifier isNewNameAddrPair(bytes32 _name, address _addr) {
    if ( idEq(_name, afd.getAddrToName(_addr)) ) revert(); //throw error if pair exists
    _;
  }


  /**
	@notice Checks if this address is associated with any id already.
	@param _addr The address to check.
  */
  modifier isUnused(address _addr) {
    if ( afd.getAddrToName(_addr) != bytes32("") ) revert();
    _;
  }

  modifier isNewName(bytes32 _name) {
    if ( afd.idInitialized(_name) revert();
    _;
  }

  /**
     @notice Checks if a name exists to prevent duplicates from being created.
     @param _name The name of the ID
  */
  modifier nameExists(bytes32 _name) {
    if ( ! afd.idInitialized(_name) ) revert();
    _;
  }


    /**
       @notice Checks if a name is the owner of the foundationid
       @param _name The name of the ID
    */
  modifier isOwner(bytes32 _name) {
    //msg.sender should be one of the addresses that owns the master id .
    if ( compare(_name, afd.getAddrToName(msg.sender)) != 0 ) revert();
    if ( !idIsActiveAddr(_name, msg.sender) ) revert();
    _;
  }

  /**
     @notice Checks if a name is the owner of the contract
  */
  modifier isAdmin() {
    if ( compare(afd.getAddrToName(msg.sender), admin) != 0 ) revert();
    _;
  }

  modifier extender() {
    if ( msg.value != weiToExtend ) revert();
    adminBalanceWei += msg.value;
    _;
  }

  modifier idCreator() {
    if ( msg.value != weiToCreate ) revert();
    adminBalanceWei += msg.value;
    _;
  }

  //can be written better
  /**
     @notice Makes sure a foundationId has at least two addresses
     @param _name The name of the ID
  */
  modifier hasTwoAddress(bytes32 _name) {
    uint numAddrs = 0;
    for (uint i = 0; i < nameToId[_name].ownedAddresses.length; i ++) {
      if ( idOwnedAddresses(_name)[i] !=0 ) {
        numAddrs++;
        if (numAddrs > 1)
          break;
      }
    }
    require( numAddrs >= 2 );
    _;
  }


  /**
     @notice Creates the contract
     @param _adminName The name of the ID to be the admin ID
     @param _weiToExtend The amount in wei required to extend the validity of a FoundationID for 1 year.
  */
  //initializes contract with msg.sender as the first admin address
  function Foundation(address foundationDataContract, bytes32 _adminName, uint _weiToExtend, uint _weiToCreate) {
    afd = AbstractFoundationData(foundationDataContract);
    //admin should already be created in FoundationData
    if ( ! idEq(afd.getAdmin(), _adminName) ) revert();
    admin = _adminName;
    weiToExtend = _weiToExtend;
    weiToCreate = _weiToCreate;
    maxNumToDeactivateAddr = 1;
  }


  //////////////////////////////////////////////////////////
  /////  Functions for External developer interaction    ///
  //////////////////////////////////////////////////////////

  /**
     @notice Return whether two addresses are of the same FoundationId
     @param _addr1 the first address to compare
     @param _addr2 the second address to compare
     @return true if the two addresses are of the same FoundationID
  */
  function areSameId(address _addr1, address _addr2) public constant returns (bool) {
    bytes32 name1 = resolveToName(_addr1);
    bytes32 name2 = resolveToName(_addr2);
    if (compare(name1, name2) == 0 ) {
      return true;
    }
    return false;
  }

  /**
     @notice Return the FoundationID that is associated with the address.
     @param _addr the address to lookup
     @return The FoundationID
  */
  function resolveToName(address _addr) public nameExists(afd.getAddrToName(_addr)) nameActive(afd.getAddrToName(_addr)) constant returns (bytes32) {
    return afd.getAddrToName(_addr);
  }

  /**
     @notice Returns an array of addresses associated with a FoundationID
     @dev Currently external contracts cannot call this
     @param _name The name of the FoundationID to lookup
     @return an array of addresses associated with the FoundationID
  */
  function resolveToAddresses(bytes32 _name) public nameExists(_name) nameActive(_name) constant returns (address[]) {
    return afd.idOwnedAddresses(_name);
  }


  function getAddrIndex(bytes32 _name, uint index) public nameExists(_name) nameActive(_name) constant returns (address) {
    require( index < afd.idOwnedAddresses(_name).length );
    return afd.idOwnedAddresses(_name)[index];
  }

  /**
     @notice Gets length of address array for foundationId
     @param _name the name of the foundationid
     @return the number of addresses associated with a user
  */
  function getAddrLength(bytes32 _name) public nameExists(_name) nameActive(_name) constant returns (uint) {
    return afd.idOwnedAddresses(_name).length;
  }


  /**
     @notice Returns whether an address has a FoundationId associated with it or not.
     @param _addr the address to lookup
     @return true if there is a foundationid for the address, false otherwise
  */
  function hasName(address _addr) public constant returns (bool) {
    if (compare(afd.getAddrToName(_addr), bytes32(0)) != 0)
      return true;
    else
      return false;
  }


  /**
     @notice Checks whether an address is associated with a FoundationID
     @param _addr The address of the to check
     @param _name The name of the FoundationID
     @return returns true of _addr and _name are associated with each other
  */
  function isUnified(address _addr, bytes32 _name) public nameActive(_name) constant returns (bool) {
    return idEq(afd.getAddrToName(_addr), _name);
  }

  /**
     @notice Set the amount of Wei required to extend a FoundationID for 1 year.
     @param _weiToExtend The amount of wei needed to extend the id one year from now
  */
  function alterWeiToExtend(uint _weiToExtend) public isAdmin {
    weiToExtend = _weiToExtend;
  }


  /**
     @notice Set the amount of Wei required to create a new id
     @param _weiToCreate The amount of wei needed to create a new id
  */
  function alterWeiToCreate(uint _weiToCreate) public isAdmin {
    weiToCreate = _weiToCreate;
  }

  /**
     @notice Get the amount of Wei required to extend a FoundationID for 1 year.
  */
  function getWeiToExtend() public constant returns (uint weiAmount) {
    return weiToExtend;
  }

  /**
     @notice Get the amount of Wei required to create a new id
  */
  function getWeiToCreate() public constant returns (uint weiAmount) {
    return weiToCreate;
  }

  /**
     @notice Extends a FoundationID for 1 year if the exact amount for the fee is sent.
     @param _name the name of the ID to extend.
  */
  //msg.value
  //adds a year to the end of now, if the balance is right
  function extendIdOneYear(bytes32 _name) public payable extender nameExists(_name) {
    if ( msg.value != weiToExtend ) revert();
    adminBalanceWei += msg.value;
    afd.setIdActiveUntil(now + extensionPeriod);
  }

  /**
     @notice Deposit Wei into the FoundationID.  This deposit is then withdrawable by any address associated with that FoundationID
  */
  //should this use safeMath add?
  function depositWei() public payable {
    bytes32 user = afd.getAddrToName(msg.sender);
    uint dbw = afd.idDepositBalanceWei(user);
    afd.setDepositBalanceWei(user, dbw + msg.value);
  }

  /**
     @notice get the amount of wei on deposit at a given FoundationID
     @param _name the name of the FoundationID.
  */
  function getDepositWei(bytes32 _name) public nameExists(_name) constant returns (uint) {
    return afd.idDepositBalanceWei(_name);
  }

  function getExpirationDate(bytes32 _name) constant returns (uint) {
    return afd.idActiveUntil(_name);
  }

  function initNameAddrPair(bytes32 _name, address _addr) private {
    afd.setAddrToName(_name, _addr);
  }

  /**
     @dev Start creating a new FoundationID
     @param _name foundationId name
     @param _addr the address
  */
  function linkAddrToId(bytes32 _name, address _addr) private {
    afd.pushIdOwnedAddresses(_name, _addr);
    afd.setIdActiveAddr(_name, _addr, true);
  }

  /**
     @notice create a new FoundationID.
     @dev private function called by createId
     @param _name the name of the new FoundationID
     @param _addr The address of the creator.
  */
  function createIdPrivate(bytes32 _name, address _addr, uint _activeUntil) isNewName(_name) private {
    initNameAddrPair(_name, _addr);
    //initialized in an inactive state
    afd.setIdInitialized(_name, true);
    afd.setIdActiveUntil(_name, _activeUntil);
    afd.setIdName(_name, _name);
    afd.setIdDepositBalanceWei(_name, 0);
    linkAddrToId(_name, _addr);
  }

  /**
     @notice create a new FoundationID.
     @param _name the name of the new FoundationID
  */
  function createId(bytes32 _name) public idCreator isUnused(msg.sender) isNewName(_name) payable {
    uint _activeUntil = now + extensionPeriod;
    createIdPrivate(_name, msg.sender, _activeUntil);
  }


  /**
     @notice Add an address to a FoundationID, must be added from existing address associated with the FoundationID
     @param _addr the new address to add.
  */
  function addPendingUnification(address _addr) public isUnused(_addr) {
    bytes32 user = afd.getAddrToName(msg.sender);
    afd.setIdPendingOwned(user, _addr);
    afd.setPendings(user, _addr);
  }


  /**
     @notice Confirm an address to be added to a FoundationID
     @dev This must be confirmed by the pending address.
     @param _name the name of the FoundationID to add the address to.
  */
  function confirmPendingUnification(bytes32 _name) public isUnused(msg.sender) {
    if ( afd.idPendingOwned(_name) != msg.sender ) revert();
    initNameAddrPair(_name, msg.sender);
    linkAddrToId(_name, msg.sender);
    afd.clearIdPendingOwned(_name);
    afd.setIdPendingOwned(bytes32(0), msg.sender);
  }

  /**
     @dev Returns the address, if any, up for unification
     @param _name the name of the FoundationID to query
  */
  function sentPending(bytes32 _name) constant returns (address) {
    return afd.idPendingOwned(_name);
  }

  function todoPending(address _addr) constant returns (bytes32) {
    return afd.getPending(_addr);
  }


  /**
     @dev Finds the index of an address in the user's foundationId ownedAddresses
     @param _name the name of the FoundationID to search through.
     @param _addr the address to find.
  */
  function findAddr(bytes32 _name, address _addr) private constant returns(uint)  {
    uint foundAddrIndex;
    for (uint i = 0; i <= afd.idOwnedAddresses(_name).length; i ++) {
      if ( afd.idOwnedAddresses(_name)[i] == _addr) {
         foundAddrIndex = i;
         return foundAddrIndex;
      }
    }
    revert(); // something went wrong if it's not found but passed previous modifiers
  }


  /**
     @notice Deletes an address
     @dev Must have at least 2 addresses otherwise throws
     @param _addr the address to delete
  */
  function deleteAddr(address _addr) public nameExists(afd.getAddrToName(_addr)) isOwner(afd.getAddrToName(_addr)) hasTwoAddress(afd.getAddrToName(_addr)) {
    bytes32 idName = afd.getAddrToName(msg.sender);
    uint addrIndex = findAddr(idName, _addr);
    afd.deleteAddrAtIndex(addrIndex);
  }


   /**
	@notice allows the admin of the contract with withdraw ethereum received through FoundationID extension payments.
        @param amount the amount to withdraw in wei
        @return success if operation was successful or not
  */
  function withdraw(uint amount) public isAdmin returns (bool success) {
    if ( adminBalanceWei < amount ) revert();
    adminBalanceWei -= amount;
    return msg.sender.send(amount);
  }

   /**
	@notice allows owner of FoundationID to withdraw ethereum from their deposited amount
        @param amount The amount in wei to withdraw
        @return success if operation was successful or not
  */

  ///removed isOwner(addrToName[msg.sender])
  //changed require to check if balance is greater than or equal to the amount
  // should use SafeMath?
  // should have a check on the size of the integer ala openzeppelin transfer functions?
  function withdrawDeposit(uint amount) public returns (bool success) {
    require (amount > 0);
    bytes32 user = afd.getAddrToName(msg.sender);
    uint bAmount = afd.idDepositBalanceWei(user);
    require ( bAmount >= amount );
    afd.setIdDepositBalanceWei(user, bAmount - amount);
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

  function member(address e, address[] l) public constant returns(bool) {
    for ( uint i=0; i<l.length; i++ ) {
      if ( l[i] == e ) return true;
    }
    return false;
  }

  function idEq(bytes32 _id1, bytes32 _id2) public constant returns (bool) {
    return ( compare(_id1, _id2) == 0 );
  }
}
