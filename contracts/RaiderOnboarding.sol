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

    CharacterAttributes[] defaultCharacters;

    // maps the NFT uuid to the struct of CharacterAttributes
    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

    // we will have many owners, each with a different NFT
    mapping(address => uint256) public nftHolders;

    constructor(
        string[] memory userNames,
        string[] memory characterImageURIs,
        string[] memory roles,
        string[][] memory skills,
        string[] memory timezones
    )
    // NFT/token symbol, like ETH or BTC
    ERC721("Raiders", "RAIDER")
    {
        for(uint i = 0; i < userNames.length; i += 1) {
            defaultCharacters.push(CharacterAttributes({
                userName: userNames[i],
                imageURI: characterImageURIs[i],
                guildRole: roles[i],
                skills: skills[i],
                timezone: timezones[i]
            }));

        }
        // first NFT has an ID of 1
        _tokenIds.increment();
    }
    function mintCharacterNFT(uint _characterIndex) external {

        // Get current tokenId (starts at 1 since we incremented in the constructor).
        uint256 newItemId = _tokenIds.current();

        // Assigns the tokenId to the caller's wallet address
        _safeMint(msg.sender, newItemId);

        // we already have an array of characters
        // now we pull them out as this function is called and the contract records
        // to whom that character belongs

        nftHolderAttributes[newItemId] = CharacterAttributes({
            userName: defaultCharacters[_characterIndex].userName,
            imageURI: defaultCharacters[_characterIndex].imageURI,
            guildRole: defaultCharacters[_characterIndex].guildRole,
            skills: defaultCharacters[_characterIndex].skills,
            timezone: defaultCharacters[_characterIndex].timezone
        });

        console.log("Minted NFT w/ tokenId %s and characterIndex %s", newItemId, _characterIndex);

        // Keep an easy way to see who owns what NFT.
        nftHolders[msg.sender] = newItemId;

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
