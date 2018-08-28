# Avoiding Common Attacks

## Mutexes 
I uses mutexes to lock both the user and (if they have one) their linked creator account so that it prevents agains reentry. 
This is how i lock a user: 
<p align="center">  
  <img
   src="https://github.com/Nicca42/MVP/blob/master/img/LockUser.PNG" alt="User Lock"/>
  <br>
</p>

This is how I unlock a user:
<p align="center">  
  <img
   src="https://github.com/Nicca42/MVP/blob/master/img/UnLockUser.PNG" alt="User unlcok"/>
  <br>
</p>

I use the mutex for any state change. Like setting up a new creator:
<p align="center">  
  <img
   src="https://github.com/Nicca42/MVP/blob/master/img/usingMutex.PNG" alt="User unlcok"/>
  <br>
</p>

## Forcibly sending Ether
This will not break any contract and all extra Ether in any of the contracts will be sent to the minter when they are upgraded. This excess Ether will be used for the moderator fund. 

## Pull over Push Payments 
The user must pull funds. 
A creator must first transfer all their views to their user account in order to withdraw them. 
<p align="center">  
  <img
   src="https://github.com/Nicca42/MVP/blob/master/img/CreatorTransfer.PNG" alt="User unlcok"/>
  <br>
</p>


## Circuit Breakers
All contracts employ an emergency stop. 
All contracts also include a pause function that is linked to the dataStorages pause. This is so that no functionality is enabled untill the data storage contract has been correctly set up. 
<p align="center">  
  <img
   src="https://github.com/Nicca42/MVP/blob/master/img/PauseFunction.PNG" alt="User unlcok"/>
  <br>
</p>

## Weaknesses 
There are points in the contract where I loop through arrays without haveing a catch for excceding a block. I felt this was not vital in this stage. 

Thank you for your time.
