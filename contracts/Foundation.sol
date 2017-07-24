pragma solidity ^0.4.11;

/**
@title Foundation
@author Timothy Galebach, Jared Bowie
@dev An ID that unifies a single users multiple addresses on the Ethereum blockchain.
*/

contract Foundation {

  bytes32 admin; //the master id associated with the admin
  uint weiToExtend; //amount of eth needed to extend a year
  uint weiToCreate;
  uint adminBalanceWei;
  uint8 maxNumToDeactivateAddr;
  uint extensionPeriod = 60*60*24*365;
  mapping ( address => bytes32 ) pendings;
  //  uint addrSize=50;

  struct FoundationId {
    bool initialized;
    address[] ownedAddresses;
    address pendingOwned; //an address requiring confirmation to add to owned
    uint activeUntil; //the date/time when this id deactivates
    uint depositBalanceWei; //how much deposit this owner has
    bytes32 name;
    mapping ( address => bool ) activeAddr;
  }

  mapping ( address => bytes32 )  addrToName;
  mapping ( bytes32  => FoundationId ) nameToId;

  /**
	@notice Checks whether a name is active according to it's activeUntil parameter.
	@param _name The name of the ID
  */


  modifier nameActive(bytes32 _name) {
    if ( nameToId[_name].activeUntil < now ) revert();
    _;
  }

  /**
	@notice Checks if this address is already in this name.
	@param _name The name of the ID.
	@param _addr The address to check.
  */

  modifier isNewNameAddrPair(bytes32 _name, address _addr) {
    if ( idEq(_name, addrToName[_addr]) ) revert(); //throw error if pair exists
    _;
  }


  /**
	@notice Checks if this address is associated with any id already.
	@param _addr The address to check.
  */

  modifier isUnused(address _addr) {
    if ( addrToName[_addr] != bytes32("") ) revert();
    _;
  }

  modifier isNewName(bytes32 _name) {
    if ( nameToId[_name].initialized ) revert();
    _;
  }

  /**
	@notice Checks if a name exists to prevent duplicates from being created.
	@param _name The name of the ID
  */

  modifier nameExists(bytes32 _name) {
    if ( ! nameToId[_name].initialized ) revert();
    _;
  }


   /**
	@notice Checks if a name is the owner of the foundationid
	@param _name The name of the ID
  */

  modifier isOwner(bytes32 _name) {
    //msg.sender should be one of the addresses that owns the master id .
    if ( compare(_name, addrToName[msg.sender]) != 0 ) revert();
    if ( !nameToId[_name].activeAddr[msg.sender] ) revert();
    _;
  }

   /**
	@notice Checks if a name is the owner of the contract
  */

  modifier isAdmin() {
    if ( compare(addrToName[msg.sender], admin) != 0 ) revert();
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
    bool hasAddress1=false;
    bool hasAddress2=false;
    for (uint i = 0; i < nameToId[_name].ownedAddresses.length; i ++) {
      if (nameToId[_name].ownedAddresses[i]!=0) {
        if (hasAddress1) {
          hasAddress2=true;
          break;
        }
        else {
          hasAddress1=true;
        }
      }
    }
    require(hasAddress1);
    require(hasAddress2);
    _;
  }


   /**
	@notice Creates the contract
	@param _adminName The name of the ID to be the admin ID
	@param _weiToExtend The amount in wei required to extend the validity of a FoundationID for 1 year.

  */

  //initializes contract with msg.sender as the first admin address
  function Foundation(bytes32 _adminName, uint _weiToExtend, uint _weiToCreate) {
    admin = _adminName;
    createIdPrivate(_adminName, msg.sender, (2**256 - 1));
    weiToExtend = _weiToExtend;
    weiToCreate = _weiToCreate;
    maxNumToDeactivateAddr = 1;
  }


  /////////////////////////////////////////////////
  /////Functions for External developer interaction
  ////////////////////////////////////////////////

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
    //can't return false as it will throw when the modifiers of resolveToName are run
  }


  /**
     @notice Return the FoundationID that is associated with the address.
     @param _addr the address to lookup
     @return The FoundationID
  */


  function resolveToName(address _addr) public nameExists(addrToName[_addr]) nameActive(addrToName[_addr]) constant returns (bytes32) {
    return addrToName[_addr];
  }

   /**
	@notice Returns an array of addresses associated with a FoundationID
        @dev Currently external contracts cannot call this
        @param _name The name of the FoundationID to lookup
        @return an array of addresses associated with the FoundationID
  */

  function resolveToAddresses(bytes32 _name) public nameExists(_name) nameActive(_name) constant returns (address[]) {
    return nameToId[_name].ownedAddresses;
  }


  function getAddrIndex(bytes32 _name, uint index) public nameExists(_name) nameActive(_name) constant returns (address) {
    require(index<nameToId[_name].ownedAddresses.length);
    return nameToId[_name].ownedAddresses[index];
  }


     /**
	@notice Gets length of address array for foundationId
        @param _name the name of the foundationid
        @return the number of addresses associated with a user
  */

  function getAddrLength(bytes32 _name) public nameExists(_name) nameActive(_name) constant returns (uint) {
    return nameToId[_name].ownedAddresses.length;
  }


  /**
	@notice Returns whether an address has a FoundationId associated with it or not.
        @param _addr the address to lookup
        @return true if there is a foundationid for the address, false otherwise

   */

  function hasName(address _addr) public constant returns (bool) {
    if (compare(addrToName[_addr], bytes32(0)) != 0) {
      return true;
    }
    else {
      return false;
    }
  }

   /**
	@notice Checks whether an address is associated with a FoundationID
	@param _addr The address of the to check
	@param _name The name of the FoundationID
        @return returns true of _addr and _name are associated with each other

  */

  function isUnified(address _addr, bytes32 _name) public nameActive(_name) constant returns (bool) {
    return idEq(addrToName[_addr], _name);
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
    nameToId[_name].activeUntil = now + extensionPeriod;
  }

   /**
	@notice Deposit Wei into the FoundationID.  This deposit is then withdrawable by any address associated with that FoundationID
  */

  //removed nameExists(addrToName[msg.sender])
  //removed isOwner(addrToName[msg.sender])
  //should this use safeMath add?
  function depositWei() public payable {
    nameToId[addrToName[msg.sender]].depositBalanceWei += msg.value;
  }

   /**
	@notice get the amount of wei on deposit at a given FoundationID
	@param _name the name of the FoundationID.
  */

  function getDepositWei(bytes32 _name) public nameExists(_name) constant returns (uint) {
    return nameToId[_name].depositBalanceWei;
  }

  function getExpirationDate(bytes32 _name) constant returns (uint) {
    return nameToId[_name].activeUntil;
  }

   /*
	@notice Change the number of addresses associated with FoundationID required to deactivate another address.
	@param _name the name of the FoundationID.
        @param newNumToD the new number of addresses required to deactivate.


  function alterNumToDeactivate(bytes32 _name, uint8 newNumToD) isOwner(_name) {
    if ( newNumToD < 2 ) revert();
    if ( newNumToD > maxNumToDeactivateAddr ) revert();
    nameToId[_name].numToDeactivateAddr = newNumToD;
  }*/

  function initNameAddrPair(bytes32 _name, address _addr) private {
    addrToName[_addr] = _name;
  }

   /**
	@dev Start creating a new FoundationID
        @param _name foundationId name
        @param _addr the address
  */



  function linkAddrToId(bytes32 _name, address _addr) private {
   // uint freeIndex = findFree(_name);
    nameToId[_name].ownedAddresses.push(_addr);
    nameToId[_name].activeAddr[_addr] = true;
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
    nameToId[_name].initialized = true;
    nameToId[_name].activeUntil = _activeUntil;
    nameToId[_name].name = _name;
    nameToId[_name].depositBalanceWei = 0;
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
    nameToId[addrToName[msg.sender]].pendingOwned = _addr;
    pendings[_addr] = addrToName[msg.sender];
  }

   /**
	@notice Confirm an address to be added to a FoundationID
        @dev This must be confirmed by the pending address.
        @param _name the name of the FoundationID to add the address to.
  */

  function confirmPendingUnification(bytes32 _name) public isUnused(msg.sender) {
    if ( nameToId[_name].pendingOwned != msg.sender ) revert();
    initNameAddrPair(_name, msg.sender);
    linkAddrToId(_name, msg.sender);
    nameToId[_name].pendingOwned = 0;
    pendings[msg.sender] = bytes32("");
  }

   /**
        @dev Returns the address, if any, up for unification
        @param _name the name of the FoundationID to query
   */

  function sentPending(bytes32 _name) constant returns (address) {
    return nameToId[_name].pendingOwned;
  }

  function todoPending(address _addr) constant returns (bytes32) {
    return pendings[_addr];
  }

   /**
        @dev Finds the index of an address in the user's foundationId ownedAddresses
        @param _name the name of the FoundationID to search through.
        @param _addr the address to find.

  */

  function findAddr(bytes32 _name, address _addr) private constant returns(uint)  {
    uint foundAddrIndex;
    for (uint i = 0; i <= nameToId[_name].ownedAddresses.length; i ++) {
       if (nameToId[_name].ownedAddresses[i]==_addr) {
         foundAddrIndex=i;
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


  function deleteAddr(address _addr) public nameExists(addrToName[_addr]) isOwner(addrToName[_addr]) hasTwoAddress(addrToName[_addr]) {
    bytes32 idName=addrToName[msg.sender];
    FoundationId foundId = nameToId[idName];
    uint addrIndex=findAddr(idName, _addr);
    delete foundId.ownedAddresses[addrIndex];
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
    require ( nameToId[addrToName[msg.sender]].depositBalanceWei >= amount );
    nameToId[addrToName[msg.sender]].depositBalanceWei -= amount;
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
