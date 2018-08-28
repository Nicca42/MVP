# Design Pattern Decisions

## Overview
When I first designed this project it was vastly different to how it is now, and probably vastly different from its final form. There where many steps in this planning process. 
Contract planning:
<p align="center">  
  <img
   src="https://github.com/Nicca42/MVP/blob/master/img/MVPContractStructureCompleate.JPG" alt="Contract structure"/>
  <br>
</p>
<p align="center">  
  <img
   src="https://github.com/Nicca42/MVP/blob/master/img/ContractPlanning.JPG" alt="Contract structure"/>
  <br>
</p>
<p align="center">  
  <img
   src="https://github.com/Nicca42/MVP/blob/master/img/MVP%20Contract%20structure.JPG" alt="Contract structure"/>
  <br>
</p>
The UI on the other hand is behind where it was planned to be:

<p align="center">  
  <img src="https://github.com/Nicca42/MVP/blob/master/img/UI%20First%20design.JPG" alt="Moderator and wannabes explained"/>
  <br>
</p>

The contracts are disigned with absolute moderlization and upgradibility as well as moduralization

<p align="center">  
  <img src="https://github.com/Nicca42/MVP/blob/master/img/HighLevelOverviewOfMVP.JPG" alt="Moderator and wannabes explained"/>
  <br>
</p>

This project implements upgradability, as can be seen by the complete separation of dataStorage and data manipulation. 
The system is designed so that endpoints (user and creator) have no access to writing to storage at any time. 

<p align="center">  
  <img
   src="https://github.com/Nicca42/MVP/blob/master/img/systemArchitecture.png" alt="Sequence Diagram of User creation"/>
  <br>
</p>

For example, if a user wanted to buy views they would have to request it in their user contract. 
This request will then get sent to the LoveMachine, which will in turn call the data storage and manipulate the data. 
This means that the data is validated, and the sender can only ever be the LoveMachine for any valued calls. 

It is important to note that views are not an ERC20 token but are an internal counter. This is so no views can leave the system. 

## Upgradability 
The contracts store no data, and are all connected to the register. `The Register.sol` has access to the data storage and can only be manipulated by the owner. The register will delete previous versions, save their addresses and push out the new address to the dataStorage. 
None of the contract (with the exception of User and Creator) store other contract addeses. They all pull from the data storage, so that if a new contract where to be deployed they would all instantly disregard the old one and user the new one, without affecting the users too deeply. 

## Separation of Concerns
This system is very modular, and each contract has a very specific job. 

  `DataStorage.sol`       : To store all data, 
                            all data changes,
                            has specific modifiers to restrict access to functions intended for     specific contracts
`Register.sol`            : Updating contracts
`UserFacotry.sol`         : Creating new users 
                            Acting as access point for users
`ContentCreatorFacotry.sol` : Creating new creators
                            Access point for creators
`LoveMachine.sol`         : Allows for any value transfers
`User.sol`                : Gives access to system
                            Allows for user functionality
`ContentCreator.sol`      : Allowing for content creation
                            Contains all content views (from likes, loves and fan loves)

## Mutexes
I used mutexes in the data storage in order to prevent a user or content creator from reentry attacks. See more in avoiding attacks documentation. 

Thank you for your time.



