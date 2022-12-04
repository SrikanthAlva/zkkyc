// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Imports
// ========================================================
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "./lib/GenesisUtils.sol";
import "./interfaces/ICircuitValidator.sol";
import "./verifiers/ZKPVerifier.sol";

// Main Contract
// ========================================================
contract ERC721Verifier is ERC721, ZKPVerifier {
    // Variables
    uint64 public constant TRANSFER_REQUEST_ID = 1;
    string public constant AADHAR_TOKEN_URI =
        "https://ipfs.io/ipfs/bafybeicvwdntxfx4fb5xrg2mnu2inpt3m256rnzcddbf6vqjyibp5y66nm/Aadhar.json";
    string public constant DRIVERLICENSE_TOKEN_URI =
        "https://ipfs.io/ipfs/bafybeicvwdntxfx4fb5xrg2mnu2inpt3m256rnzcddbf6vqjyibp5y66nm/DriverLicense.json";
    string private erc721Name;
    string private erc721Symbol;
    mapping(uint256 => address) public idToAddress;
    mapping(address => uint256) public addressToId;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    constructor(
        string memory name_,
        string memory symbol_
    ) ERC721(name_, symbol_) {
        erc721Name = name_;
        erc721Symbol = symbol_;
    }

    function _beforeProofSubmit(
        uint64 /* requestId */,
        uint256[] memory inputs,
        ICircuitValidator validator
    ) internal view override {
        // check that challenge input of the proof is equal to the msg.sender
        address addr = GenesisUtils.int256ToAddress(
            inputs[validator.getChallengeInputIndex()]
        );
        require(
            _msgSender() == addr,
            "address in proof is not a sender address"
        );
    }

    function _afterProofSubmit(
        uint64 requestId,
        uint256[] memory inputs,
        ICircuitValidator validator
    ) internal override {
        require(
            requestId == TRANSFER_REQUEST_ID && addressToId[_msgSender()] == 0,
            "proof can not be submitted more than once"
        );

        uint256 id = inputs[validator.getChallengeInputIndex()];
        // execute the airdrop
        if (idToAddress[id] == address(0)) {
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _safeMint(_msgSender(), tokenId);
            addressToId[_msgSender()] = id;
            idToAddress[id] = _msgSender();
        }
    }

    function _beforeTokenTransfer(
        address /* from */,
        address to,
        uint256 /* amount */
    ) internal view override {
        require(
            proofs[to][TRANSFER_REQUEST_ID] == true,
            "only identities who provided proof are allowed to receive tokens"
        );
    }

    function tokenURI(
        uint256 tokenId
    ) public pure override returns (string memory) {
        return AADHAR_TOKEN_URI;
    }
}
