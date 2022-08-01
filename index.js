import axios from "axios";
import { providers, Contract, utils } from "ethers";

// A Web3Provider wraps a standard Web3 provider, which is
// what MetaMask injects as window.ethereum into each page
const provider = new providers.Web3Provider(window.ethereum);

// MetaMask requires requesting permission to connect users accounts
await provider.send("eth_requestAccounts", []);

// The MetaMask plugin also allows signing transactions to
// send ether and pay to change state within the blockchain.
// For this, you need the account signer...
const signer = provider.getSigner();

var data = JSON.stringify({
  "pinataOptions": {
    "cidVersion": 1
  },
  "pinataMetadata": {
    "name": "testing",
    "keyvalues": {
      "customKey": "customValue",
      "customKey2": "customValue2"
    }
  },
  "pinataContent": {
    "somekey": "somevalue"
  }
});

var config = {
  method: 'post',
  url: 'https://api.pinata.cloud/pinning/pinJSONToIPFS',
  headers: { 
    'Content-Type': 'application/json', 
    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySW5mb3JtYXRpb24iOnsiaWQiOiJlYWNiNmMxMy0wNmMwLTRmNTQtYTQyNS0wOTI5MzlhNDI0MjYiLCJlbWFpbCI6Inpqb3NlODhAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsInBpbl9wb2xpY3kiOnsicmVnaW9ucyI6W3siaWQiOiJOWUMxIiwiZGVzaXJlZFJlcGxpY2F0aW9uQ291bnQiOjF9XSwidmVyc2lvbiI6MX0sIm1mYV9lbmFibGVkIjpmYWxzZSwic3RhdHVzIjoiQUNUSVZFIn0sImF1dGhlbnRpY2F0aW9uVHlwZSI6InNjb3BlZEtleSIsInNjb3BlZEtleUtleSI6ImQ5NmM4NDUxOTc1YTU0NGY0Y2U2Iiwic2NvcGVkS2V5U2VjcmV0IjoiZjMxYjViZGUxMGU1YzRjOTJjZDM2ZmY4NzY0MWRjODY4YTFiMzhjMTkwOGNjYTNlMDI5N2FiOTllM2UxMDY5MiIsImlhdCI6MTY1NzE1NjQ4Mn0.bKEDMQkqSgPjj9QRHy1B-xgikKTC4KgYst7XjCcXuvY'
  },
  data : data
};

const res = await axios(config);

console.log(res.data);

// ---------------
const contract = new Contract(
  CONTRACT_ADDRESS,
  abi,
  signer
);
// Get the address associated to the signer which is connected to  MetaMask
const address = await signer.getAddress();

const tx = await contract.withdraw();

// wait for the transaction to get mined
await tx.wait();

window.alert("Contract Ether withdrew to Owner account");