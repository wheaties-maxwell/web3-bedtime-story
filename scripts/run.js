const main = async () => {
    // in order to deploy something to the blockchain, we need wallet addresses!
    // hardhat does this for us magically in the background.
    const [owner, randomPerson] = await hre.ethers.getSigners();
    // hre is the hardhat runtime environment, an object containing the functionality that hardhat exposes when running a task
    // everytime i run a terminal command "npx hardhat...", i get this hre object built on the fly with the hardhat.config.js file
    // compile contract and generate necessary files for contract under artifacts directory
    const waveContractFactory = await hre.ethers.getContractFactory("WavePortal");
    // Fund and deploy contract with 0.1 ETH
    const waveContract = await waveContractFactory.deploy({
      value: hre.ethers.utils.parseEther("0.1"),
    });
    // hardhat creates a local ethereum network for just this contract, deleting it after script completes
    // wait for contract to deploy to local blockchain
    await waveContract.deployed();
    console.log("Contract deployed to:", waveContract.address);
    console.log("Contract deployed by:", owner.address)

    /*
    * Get Contract balance
    */
   let contractBalance = await hre.ethers.provider.getBalance(
     waveContract.address
   );
   console.log(
     "Contract balance:",
     hre.ethers.utils.formatEther(contractBalance)
   );

    let totalStory;
    totalStory = await waveContract.getTotalStory();

    let addStoryTxn = await waveContract.addStory("Hello world!", "A message!");
    await addStoryTxn.wait();

    addStoryTxn = await waveContract.connect(randomPerson).addStory("It's me!", "Another message!");
    await addStoryTxn.wait();

    /*
    * Get Contract balance to see what happened!
    */
    contractBalance = await hre.ethers.provider.getBalance(waveContract.address);
    console.log(
      "Contract balance:",
      hre.ethers.utils.formatEther(contractBalance)
    );

    let allStories = await waveContract.getAllStories();
    console.log(allStories);
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