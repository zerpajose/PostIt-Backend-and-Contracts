// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PostIt is ERC721, ERC721URIStorage, Ownable {

  using Counters for Counters.Counter;
  
  // uint -> id from document; address[4] -> list of collaborators
  mapping(uint => address[4]) public collaborators;

  // In order to mint an nft, user needs to deposit an stake (will be returned if burn the NFT)
  uint256 public stakeAmount = 0.001 ether;
  // You will be added to AL when you do the stake deposit
  mapping(address => bool) public allowList;

  // which nfts have an address
  mapping(address => uint[]) public postsPerAddress;

  Counters.Counter private _tokenIdCounter;

  constructor() ERC721("PostIt", "POSTIT") {}

  event minted(address indexed _from, string indexed _uri);

  // verify if caller is a collaborator
  modifier onlyCollaboratorsAndOwner(uint _id) {

    bool _flag1;
    bool _flag2;

    // if colaborator from this _id
    for (uint256 index = 0; index < collaborators[_id].length; index++) {
      if(collaborators[_id][index] == msg.sender){
        _flag1 = true;
        break;
      }
    }

    // if owner from this _id
    if (msg.sender == ownerOf(_id)){
      _flag2 = true;
    }

    require(_flag1 || _flag2, "You are not a collaborator or owner");
    _;
  }

  function safeMint(string memory uri) public {
    require(allowList[msg.sender], "You are not in the AllowList");
    address _to = msg.sender;
    emit minted(_to, uri);
    
    uint256 tokenId = _tokenIdCounter.current();
    _tokenIdCounter.increment();
    _safeMint(_to, tokenId);
    _setTokenURI(tokenId, uri);
    postsPerAddress[_to].push(tokenId);
  }

  // The following functions are overrides required by Solidity.

  function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
    super._burn(tokenId);
  }

  function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
    return super.tokenURI(tokenId);
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

  //AllowList
  // Add msg.sender to WL
  function setAllowList() external payable {
    require(stakeAmount <= msg.value, "Ether value sent is not correct");
    allowList[msg.sender] = true;
  }

  // Withdraw the Ether from the contract to the NFT owner
  function withdrawStake(uint _id) public {
    require(msg.sender == ownerOf(_id), "Not owner of this NFT");
    payable(msg.sender).transfer(stakeAmount);
    allowList[msg.sender] = false;
  }

  // Update URI from tokenID
  function updatePostURI(uint _id, string memory _uri) public onlyCollaboratorsAndOwner(_id) {
    _setTokenURI(_id, _uri);
  }

  // get nfts ids from address
  function getNftsIdsFromAddress(address _owner) public view returns(uint[] memory) {
    return postsPerAddress[_owner];
  }
}
