## Depositing and Withdrawing Ethereum
The Foundation smart contract provides the ability to deposit and withdraw Ethereum.  This should not be confused with wallet functionality.  This is not intended to be used as a general wallet and has limitations in place to prevent that usage.

The intended usecase for the deposit function is for specific dapps to require a minimum amount deposited so that users are cautious about adding other addresses that they don't control to their FoundationId.  In essence this is a mechanism to help assure dapps that only one person is using a FoundationId.   If users do decide to share their FoundationId, they will then risk their deposit being lost by any other user who has access to it.  **Don't share your FoundationId or you might lose your entire deposit.**

## Depositing Ethereum
Use the depositWei function to add a deposit to a FoundationId.  You must send the amount of Ethereum you wish to deposit along with the function call. 
```javascript
  function depositWei() payable {}
 ```
 ## Checking the Deposit Balance
 To check the balance of any user's deposit call getDepositWei.  This function will return the balance in wei that the user is currently holding in their foundationId.
 ```javascript
   function getDepositWei(bytes32 _name) nameExists(_name) constant returns (uint) {}
  ```
##### Arguments 
* _name:  The name of the FoundationId who's deposit balance you wish to check.
##### Modifiers
* nameExists: Checks to make sure the foundationId exists.
##### Returns
Returns the balance in wei held by the FoundationId.
## Withdrawing Ethereum
To withdraw Ethereum from your FoundationId deposit balance use the withdrawDeposit function.  
```javascript
 function withdrawDeposit(uint amount) returns (bool success) {}
 ````
##### Arguments 
* amount:  The amount of Ethereum in wei to withdraw.
##### Returns
Returns whether the transaction was a success or not.
