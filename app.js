const express = require("express");
const fs = require('fs');
require("dotenv").config({ path: ".env" });
const cors = require('cors');

const axios = require('axios');
const FormData = require('form-data');

const Web3Token = require('web3-token');

const { ethers } = require("ethers");

const { POSTIT_CONTRACT_ADDRESS, POSTIT_CONTRACT_ABI } = require("./constants/index");

const PINATA_BEARER = process.env.PINATA_BEARER;
const ALCHEMY_API_KEY_URL = process.env.ALCHEMY_API_KEY_URL;

const app = express();
app.use(express.json());

app.use(express.urlencoded({ extended: true }));

app.use(cors());

app.post("/postit", newPost);

async function newPost(req, res) {

  const token = req.headers['authorization'];

  const { address } = await Web3Token.verify(token);

  const contractOwner = await getOwner();

  if(ethers.utils.getAddress(address) !== ethers.utils.getAddress(contractOwner)){
    res.json({msg: "Not Contract Owner"});
    res.end();
  }

  const new_post = req.body;

  console.log(JSON.stringify(req.body));

  /* 
   *  Upload metadata to IPFS
   */ 
  const data_metadata = JSON.stringify(
    {
      "image": `https://gateway.pinata.cloud/ipfs/QmTiPi5ELw9Zit7bLbxhEj1nyUxaoTuLQAN8hHWb8aRp69`,
      "name": new_post.name,
      "attributes": [
        {
          "trait_type": "description",
          "value": new_post.description
        }
      ]
    });
  
  const config_metadata = {
    method: 'post',
    url: 'https://api.pinata.cloud/pinning/pinJSONToIPFS',
    headers: { 
      'Content-Type': 'application/json',
      'Authorization': PINATA_BEARER
    },
    data: data_metadata
  };
  
  const response_metadata = await axios(config_metadata);

  console.log(response_metadata.data.IpfsHash);
  
  res.json({IpfsHash: response_metadata.data.IpfsHash});

  res.end();
}
  
app.post("/is_owner", isOwner);

async function isOwner(req, res) {

  const contractOwner = await getOwner();

  const token = req.headers['authorization'];

  const { address, body } = await Web3Token.verify(token);

  if(ethers.utils.getAddress(address) === ethers.utils.getAddress(contractOwner)){

    res.json({is_owner: true, token: token, owner_address: ethers.utils.getAddress(contractOwner)});
  }
  else{
    res.json({is_owner: false, token: token});
  }
  res.end();
}

async function getOwner(){
  
  const customHttpProvider = new ethers.providers.JsonRpcProvider(ALCHEMY_API_KEY_URL);

  const postItContract = new ethers.Contract(POSTIT_CONTRACT_ADDRESS, POSTIT_CONTRACT_ABI, customHttpProvider);

  const contractOwner = await postItContract.owner();

  return contractOwner;
}

app.listen(3001, () => {
  console.log(`Server started at port 3001`);
});
