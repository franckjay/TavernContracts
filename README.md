# Raider Onboarding

This repo begins our simple contract to mint an NFT with attributes helpful for a new Raider.

To run this, you will need to create a `.env` file, copying `.env.sample`.

After that, `npx hardhat run scripts/run.js` should work.

It has been deployed on rinkeby with `npx hardhat run scripts/deploy.js --network rinkeby`.

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
node scripts/sample-script.js
npx hardhat help
```

Next to-dos:
- Deploy to Polygon testnet
- Check that the NFT is visible on opensea
