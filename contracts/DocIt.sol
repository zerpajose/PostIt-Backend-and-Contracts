// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract DocIt is ERC721, ERC721URIStorage, Ownable {

  using Counters for Counters.Counter;
  
  mapping(uint => address[4]) public collaborators;

  // In order to mint an nft, user needs to deposit an stake (will be returned if burn the NFT)
  uint256 public stakeAmount = 0.001 ether;
  // You will be added to AL when you do the stake deposit
  mapping(address => bool) public allowList;

  Counters.Counter private _tokenIdCounter;

  constructor() ERC721("DocIt", "DOCIT") {}

  event minted(address indexed _from, string indexed _uri);

  function safeMint(string memory uri) public {
    require(allowList[msg.sender], "You are not in the AllowList");
    address _to = msg.sender;
    emit minted(_to, uri);
    
    uint256 tokenId = _tokenIdCounter.current();
    _tokenIdCounter.increment();
    _safeMint(_to, tokenId);
    _setTokenURI(tokenId, uri);
  }

  // The following functions are overrides required by Solidity.

  function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
    super._burn(tokenId);
  }

  function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
    return super.tokenURI(tokenId);
  }

  //AllowList
  // Add msg.sender to WL
  function setAllowList() external payable {
    require(stakeAmount <= msg.value, "Ether value sent is not correct");
    allowList[msg.sender] = true;
  }

  // Only OwnerOf this _id can add collaborators
  function addCollaborator(address _collaborator, uint _id) public {
    require(msg.sender == ownerOf(_id), "Not owner of this NFT");

    bool _flag;
    uint _index;

    for (uint256 index = 0; index < collaborators[_id].length; index++) {
      if(collaborators[_id][index] == address(0)){
        _index = index;
        _flag = true;
        break;
      }
    }

    if(_flag){
      collaborators[_id][_index] = _collaborator;
    }
    else{
      revert("Number of collaborators maxedout (4)");
    }

  }

  // Only OwnerOf this _id can remove collaborators
  function removeCollaborator(address _collaborator, uint _id) public{
    require(msg.sender == ownerOf(_id), "Not owner of this NFT");

    bool _flag;
    uint _index;

    for (uint256 index = 0; index < collaborators[_id].length; index++) {
      if(collaborators[_id][index] == _collaborator){
        _index = index;
        _flag = true;
        
        break;
      }
    }

    if(_flag){
      delete collaborators[_id][_index];
    }
    else{
      revert("Address to remove doesn't exists");
    }
  }

  // Withdraw the Ether from the contract to the NFT owner
  function withdrawStake(uint _id) public {
    require(msg.sender == ownerOf(_id), "Not owner of this NFT");
    payable(msg.sender).transfer(stakeAmount);
    allowList[msg.sender] = false;
  }
}