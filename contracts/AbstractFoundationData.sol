pragma solidity ^0.4.11;

contract AbstractFoundationData {

  /*  Setters  */
  function setIdInitialized(bytes32 fId, bool init);
  function pushIdOwnedAddresses(bytes32 fId, address _addr);
  function setIdPendingOwned(bytes32 fId, address _pendingAddr);
  function setIdDepositBalanceWei(bytes32 fId, uint wei);
  function setIdActiveUntil(bytes32 fId, unit _activeUntil);
  function setIdName(bytes32 fId, bytes32 val);
  function setIdActiveAddr(bytes32 fId, address _addr, bool val);

  /*   mapping setters  */
  function setPendings(bytes32 _name, address _addr);
  function setAddrToName(bytes32 _name, address _addr);

  /*  Getters  */
  function idInitialized(bytes32 fId) constant returns (bool);
  function idOwnedAddresses(bytes32 fId) constant returns (address[]);
  function idPendingOwned(bytes32 fId) constant returns (address);
  function idDepositBalanceWei(bytes32 fId) constant returns (uint);
  function idActiveUntil(bytes32 fId) constant returns (uint timestamp);
  function idIsActiveAddr(bytes32 fId, address _addr) constant returns (bool);

  function getPending(address _addr) constant returns (bytes32);
  function getAddrToName(address _addr) constant returns (bytes32);
}
