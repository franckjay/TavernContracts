// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// Helper we wrote to encode in Base64
import "./libraries/Base64.sol";

contract RaiderOnboarding is ERC721 {
    // these are default character attributes
    // we will start with just a cleric
    // users can update username and skills when they mint
    struct CharacterAttributes {
        string userName;
        string imageURI;
        string guildRole;
        string[] skills;
        string timezone; // GMT
        // raids completed
        // rips completed
        // quizBotPOAPs
    }

    // we will use a simple uint 0, 1, 2 as the NFT uuid
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // Our default cast of characters to choose from
    CharacterAttributes[] possibleCharacters;

    // we require two separate mappings
    // later we will use this to allow holders to update their NFTs
    mapping(address => uint256) public nftHolders;
    // ERC731 metadata tokenURI requires tokenID to be passed in
    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

    // Upon creation, the contract will have default roles, images, and timezone
    constructor(
        string[] memory characterImageURIs,
        string[] memory roles,
        string memory timezone
    )
    // NFT/token symbol, like ETH or BTC
    ERC721("Raiders", "RAIDER")
    {
        for(uint i = 0; i < roles.length; i += 1) {
            possibleCharacters.push(CharacterAttributes({
                userName: "Nemo",
                guildRole: roles[i],
                imageURI: characterImageURIs[i],
                skills: new string[](0),         // initialize as empty array
                timezone: timezone
            }));

        }
        // first NFT has an ID of 1
        _tokenIds.increment();
    }


    // the bot must pass in the correct index for the role/image
    // and specify userName, skills, and timezone
    // later we will source skills from DungeonMaster or something
    function mintCharacterNFT(uint _characterIndex, string memory userName, string[] memory skills, string memory timezone) external {

        // Get current tokenId (starts at 1 since we incremented in the constructor).
        uint256 newItemId = _tokenIds.current();

        // Assigns the tokenId to the caller's wallet address
        _safeMint(msg.sender, newItemId);

        // Create new character, map to item id
        nftHolderAttributes[newItemId] = CharacterAttributes({
            userName: userName,
            imageURI: possibleCharacters[_characterIndex].imageURI,
            guildRole: possibleCharacters[_characterIndex].guildRole,
            skills: skills,
            timezone: bytes(timezone).length != 0 ? timezone : possibleCharacters[_characterIndex].timezone
        });

        nftHolders[msg.sender] = newItemId;
        console.log("Minted NFT w/ tokenId %s and characterIndex %s", newItemId, _characterIndex);

        // Increment the tokenId for the next person that uses it.
        _tokenIds.increment();
        emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
    }
    event CharacterNFTMinted(
        address sender,
        uint256 tokenId,
        uint256 characterIndex
    );

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];

        string memory guildRole = charAttributes.guildRole;
        string memory timezone = charAttributes.timezone;

        string memory json = Base64.encode(
            abi.encodePacked(
                '{"name": "',
                charAttributes.userName,
                ' -- NFT #: ',
                Strings.toString(_tokenId),
                '", "description": "This NFT represents a new member of RaidGuild!", "image": "',
                charAttributes.imageURI,
                '", "attributes": ['
                                 '{ "trait_type": "timezone", "value": "',timezone,'" },'
                                 '{ "trait_type": "Guild Role", "value": "',guildRole,'" }'
                                ']}'
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }
}
