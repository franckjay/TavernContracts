const { baseCharacters, roleToIndex } = require("./characters");

const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory(
    "RaiderOnboarding"
  );
  const roles = baseCharacters.map((char) => char[0]);
  const avatars = baseCharacters.map((char) => char[1]);
  const gameContract = await gameContractFactory.deploy(
    roles,
    avatars,
    "GMT-6" // timezone
  );
  await gameContract.deployed();
  console.log("Contract deployed to:", gameContract.address);

  // imagine the bot sent us this:
  const choices = {
    role: "cleric",
    name: "Dan",
    skills: "dancing, singing",
    zone: "GMT-4",
  };

  const { role, name, skills, zone } = choices;

  // minting the character
  let txn = await gameContract.mintCharacterNFT(
    roleToIndex[role],
    name,
    skills,
    zone
  );
  await txn.wait();

  // Get the value of the NFT's URI.
  let returnedTokenUri = await gameContract.tokenURI(1);
  console.log("Token URI:", returnedTokenUri);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();
