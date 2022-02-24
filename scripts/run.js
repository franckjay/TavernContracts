const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory(
    "RaiderOnboarding"
  );
  const gameContract = await gameContractFactory.deploy(
    ["Ned"], // UserNames
    [
      "https://i.imgur.com/pKd5Sdk.png", // avatars
    ],
    ["cleric"], // roles
    [["writing on parchment"]], // skills
    ["GMT-6"] // timezone
  );
  await gameContract.deployed();
  console.log("Contract deployed to:", gameContract.address);

  let txn;
  // We only have three characters.
  // an NFT w/ the character at index 2 of our array.
  txn = await gameContract.mintCharacterNFT(0);
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
