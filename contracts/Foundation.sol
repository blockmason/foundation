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
	@notice Checks if a name is associated with an address, if already associated throws.
	@param _name The name of the ID.
	@param _addr The address to check.
  */

  modifier isNewNameAddrPair(bytes32 _name, address _addr) {
    if ( idEq(_name, addrToName[_addr]) ) revert(); //throw error if pair exists
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
  function Foundation(bytes32 _adminName, uint _weiToExtend) {
    admin = _adminName;
    createIdPrivate(_adminName, msg.sender, (2**256 - 1));
    weiToExtend = _weiToExtend;
    maxNumToDeactivateAddr = 1;
  }


   /*
	@notice Finds next available index in IDs address array
        @param _name the foundationId to check




  function findFree(bytes32 _name) nameActive(_name) constant returns (uint) {
    uint freeIndex=nameToId[_name].ownedAddresses.length; //past the last array slot
     for (uint i = 0; i < nameToId[_name].ownedAddresses.length; i ++) {
       if (nameToId[_name].ownedAddresses[i]==0) {
         freeIndex=i;
         break;
       }
     }
    return freeIndex;
  }
 */


   /**
	@notice Checks whether an address is associated with a FoundationID
	@param _addr The address of the to check
	@param _name The name of the FoundationID
        @return returns true of _addr and _name are associated with each other

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
    if ( msg.value != weiToExtend ) revert();
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
    if ( nameToId[_name].pendingOwned != msg.sender ) revert();
    initNameAddrPair(_name, msg.sender);
    linkAddrToId(_name, msg.sender);
    nameToId[_name].pendingOwned = 0;
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


  function deleteAddr(address _addr) nameExists(addrToName[_addr]) isOwner(addrToName[_addr]) hasTwoAddress(addrToName[_addr]) {
    bytes32 idName=addrToName[msg.sender];
    FoundationId foundId = nameToId[idName];
    uint addrIndex=findAddr(idName, _addr);
    delete foundId.ownedAddresses[addrIndex];
  }

  /**
	@notice Return whether two addresses are of the same FoundationId
        @param _addr1 the first address to compare
        @param _addr2 the second address to compare
        @return true if the two addresses are of the same FoundationID

   */

  function areSameId(address _addr1, address _addr2) constant returns (bool) {
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


  function resolveToName(address _addr) nameExists(addrToName[_addr]) nameActive(addrToName[_addr]) constant returns (bytes32) {
    return addrToName[_addr];
  }

   /**
	@notice Returns an array of addresses associated with a FoundationID
        @dev Currently external contracts cannot call this
        @param _name The name of the FoundationID to lookup
        @return an array of addresses associated with the FoundationID
  */

  function resolveToAddresses(bytes32 _name) nameExists(_name) nameActive(_name) constant returns (address[]) {
    return nameToId[_name].ownedAddresses;
  }


  function getAddrIndex(bytes32 _name, uint index) nameExists(_name) nameActive(_name) constant returns (address) {
    require(index<nameToId[_name].ownedAddresses.length);
    return nameToId[_name].ownedAddresses[index];
  }

  ///needed because can't return dynamic addresses to external contracts
  ///allows for compatibility when dynamic array support is added

  /*
  function get10Addr(bytes32 _name, uint indexStart) nameExists(_name) nameActive(_name) constant returns (address[10]) {
    address[10] memory tenAddr;
    for (uint i=0; i<10; i++) {
      if (i+indexStart < nameToId[_name].ownedAddresses.length) {
        tenAddr[i]=nameToId[_name].ownedAddresses[i+indexStart];
      }
      else {
        tenAddr[i]=0;
      }
    }
    return tenAddr;
  }
*/
     /**
	@notice Gets length of address array for foundationId
        @param _name the name of the foundationid
        @return the number of addresses associated with a user
  */

  function getAddrLength(bytes32 _name) nameExists(_name) nameActive(_name) constant returns (uint) {
    return nameToId[_name].ownedAddresses.length;
  }

   /**
	@notice allows the admin of the contract with withdraw ethereum received through FoundationID extension payments.
        @param amount the amount to withdraw in wei
        @return success if operation was successful or not
  */

  function withdraw(uint amount) isAdmin returns (bool success) {
    if ( adminBalanceWei < amount ) revert();
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
    if ( nameToId[_name].depositBalanceWei < amount ) revert();
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
