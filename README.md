## Inspiration
PostIt was inspired by the old school sticky notes, which you can take notes and check the information later.

## What it does
With PostIt you can save and update your information with a title and a description in the blockchain, also you can add collaborators to help you write and update your notes.

## How I built it
It is built with nodejs for the backend API, the information is saved on IPFS (through Pinata service) and smart contracts are deployed in Mumbai Polygon testnet. Also it has a React+Next frontend.

## Some challenges I ran into was
* The upload and pining files on IPFS.
* The possibility to sign-in with wallet.

## Accomplishments that I'm proud of
* Solving the uploading and pining files to IPFS through Pinata API Service.
* Solving the wallet sign-in with "web3-token" library.

## What I learned:
* The implementation of "web3-token" library to manage wallet sign-in.
* The implementation of an Nodejs API to generate and verify a wallet sign-in token.
* The use of Pinata API to upload and pining files to IPFS.
* The use of OpenZeppelin libraries to deploy an ERC721 standard contract.
* The modification of an ERC721 standard contract to adapt it to the use case.
* The use of AlchemyAPI to manage the connection to the blockchain.


## What's next for PostIt
The next great step for PostIt is implement a functionality to resemble a "Google Docs" for web3, allowing to create, save, update files like word proccessors, spreadsheets and presentations, becoming a office suite blockchain based.