# MVP
**Memes Videos Photos - **
**Decentralized social media, where the creators own their content and users can view content add free.**

# Overview
MVP is a social media platform much like YouTube or Instagram, but instead of covering server costs with invasive adds, users buy the ability to view content. Views are cheap and affordable, and it will not cost the user much to buy enough Views to consume content. The Views are transferred to the contents creator. 1 Eth = 100 000 Views, making each View approximately (and at the time of writing) worth 4c. This makes it affordable for the user and profitable for the creator.

## How to run the project
This project is a large and complex system of smart contracts, that require a lot of set up to correctly link and set up. As such I have deployed to Rinkeby and linked them for convenience. The front end was created with `vuejs` and `elementsUI`. The project successfully runs on Arch Linux and Ubuntu 16.04. The pre requirements for the project is `Node>=8.11`,`nmp` and `truffle`. 

#### Install libraries
In the root directory run:

    npm install
    
Then:

    npm run serve

The Rinkeby addresses can be found <a href="https://github.com/Nicca42/MVP/blob/master/deployed_addresses.txt">here</a>. To interact the system on your local machine run(in project root):

    ganache-cli

Then either:

    truffle compile
    truffle test
    truffle migrate

## MVP - Inspiration 
YouTube is one of the biggest social media platforms available, and being so big, it of course has issues. For example, it's suggestion algorithm is moderated by... another algorithm. This results in disturbingly quick 'slips' down rabbit holes from innocent content. There is a fasinating Ted talk about it: <a href="https://www.ted.com/talks/james_bridle_the_nightmare_videos_of_childrens_youtube_and_what_s_wrong_with_the_internet_today">Ted Talk - The Nightmare Videos Of Childerens YouTube</a>. My system hopes to fix this issue in two ellagant solutions.
In future versions when payment channels, or side-chains come into being reliably, the user will be charged a single view for each piece of content they consume, and (as the current system is:) pay 5 views for liking content, 15 for loving content, and 25 for fan loving content. Currently it is free to consume content. 

### No More Adds
In MVP there are no adds as the content creators make their income from people liking, loving, or fan loving their content in the native currency of views. Views are completely locked into the system, and can never be sent to an external wallet or address. This is because these views are directly linked to Ether value in the LoveMachine.sol (minter). 

### Moderators
In a future version of MPN (as it was out of current scope) the moderator functionality will be completed, allowing for moderators to rate content, their creators, and flag content. The flagging allows for a specific tag to be placed on the content, either flagging it as 18+ content, R rated content, or to be removed (hate speech, encouraging violence etc). These moderators are paid for their work by the `moderatorFund`. This fund is sponsored by: 
    The creation of a content creator.
    The buying of views (not selling).
    The uploading of new content. 

This allows for content consumers to only view from creators who have been flagged as Safe or PG13 etc. This level of control can prevent disturbing content from polluting younger users but allows for much more freedom of speech than YouTube currently allows, enabling a much larger audience with a much more secure way of viewing safe content. 

## Notes Before We Jump In
This is the first dApp I have ever created, and my first time playing with this technology stack. As such there are still bugs and this system is nowhere near complete. For this submission I tried to enable the base functionality so that a basic understanding of the system can be portrayed. 
For this project my focus was learning Solidity, which means there is little integration with the other technologies and tools, and alot of focus on the contracts. As a result of this I have learnt an incredible amount about Solidity and its specific quirks. I have thoroughly enjoyed learning Solidity and would deeply appreciate consideration for hiring, despite the lack of an extensive technology stack. 

## User Stories
The system has (in its current state) two main users:
The consumer, referred to as the user and
The creator.

### Use Case
The user first loads the web front end, and becomes a user via entering their desired username. The username and their wallet address gets sent to the UserFactory. The UserFactory then spawns a userContract and sends the information to the dataStorage. 
<p align="center">  
  <img
   src="https://github.com/Nicca42/MVP/blob/master/img/sequenceDiagram%20UC.png" alt="Sequence Diagram of User creation"/>
  <br>
</p>

The user wants to become a content creator. They load the front end and got to become a content creator. They have to have a balance of views beforehand as it costs to become a content creator. 
<p align="center">  
  <img
   src="https://github.com/Nicca42/MVP/blob/master/img/sequenceDiagram%20CCC.png" alt="Sequence Diagram of Content Creator creation"/>
  <br>
</p>

## Security Tools / Common Attacks
There were lots of vulnerabilities that I tried to avoid, but there where many that I did not have time to fix or work around. Documentation can be found <a href="https://github.com/Nicca42/MVP/blob/master/avoiding_common_attacks.md">here</a>.

## Design Pattern Decisions
There where many tricky desisions made for this, and information about this can be found <a href="https://github.com/Nicca42/MVP/blob/master/design_pattern_desicions.md">here</a>.

## Future functionality
I would like to build this out into an actual mvp/product as I think it's impact is only limited to the size of ones imagination. 
Future improvements include:
1. Moderators
    Moderators have a normal user account. They cannot be creators. They must be over 18 and have NSFW enabled in settings, as there is     no guarantee as to what they will see. They will first view content a normal user has flagged as remove (as these are probably the       most needed to be removed) and then filter down sevarity to R then 18+ etc.  
2. Content Types
    In future itterations I would like to unlimit the content types. Allowing videos, pictures, votes and polls, blogs, and anything        else I can think of. I want it to be a platform where everyone is included, the audience has control over what they do and do not        want to see without creating eco chambers, and there is no limit on conent. 
    
Thank you for your time.
