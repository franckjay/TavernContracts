const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory(
    "RaiderOnboarding"
  );
  const gameContract = await gameContractFactory.deploy(
    [
      "https://avatars.githubusercontent.com/u/100328627?s=400&u=0bf6534f1115840843d47ae0192fdf8a88062f44&v=4", // avatars
    ],
    ["cleric"], // roles
    "GMT-6" // timezone
  );
  await gameContract.deployed();
  console.log("Contract deployed to:", gameContract.address);

  // minting the character
  let txn = await gameContract.mintCharacterNFT(0, "Dan", ["dancing"], "GMT-4");
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
