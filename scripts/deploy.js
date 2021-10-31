let { rarityAddr, attributesAddr, skillsAddr, randomCodexAddr, extendedMultisig } = require("../registry.json");

async function main() {
    //Compile
    await hre.run("clean");
    await hre.run("compile");

    //Deploy loots
    this.Steamed_Mushrooms = await (await ethers.getContractFactory('Steamed_Mushrooms')).deploy();
    await this.Steamed_Mushrooms.deployed();
    
    this.Grilled_Mushrooms = await (await ethers.getContractFactory('Grilled_Mushrooms')).deploy();
    await this.Grilled_Mushrooms.deployed();
    
    this.Fruit_and_Mushroom_Mix = await (await ethers.getContractFactory('Fruit_and_Mushroom_Mix')).deploy();
    await this.Fruit_and_Mushroom_Mix.deployed();
    
    this.Meat_and_Mushroom_Skewer = await (await ethers.getContractFactory('Meat_and_Mushroom_Skewer')).deploy();
    await this.Meat_and_Mushroom_Skewer.deployed();
    
    this.Gourmet_Fruit_and_Mushroom_Mix = await (await ethers.getContractFactory('Gourmet_Fruit_and_Mushroom_Mix')).deploy();
    await this.Gourmet_Fruit_and_Mushroom_Mix.deployed();

    console.log(`Steamed_Mushrooms deployed here: ${this.Steamed_Mushrooms.address}`)
    console.log(`Grilled_Mushrooms deployed here: ${this.Grilled_Mushrooms.address}`)
    console.log(`Fruit_and_Mushroom_Mix deployed here: ${this.Fruit_and_Mushroom_Mix.address}`)
    console.log(`Meat_and_Mushroom_Skewer deployed here: ${this.Meat_and_Mushroom_Skewer.address}`)
    console.log(`Gourmet_Fruit_and_Mushroom_Mix deployed here: ${this.Gourmet_Fruit_and_Mushroom_Mix.address}`)

    //Deploy
    this.BoarsCook = await (await ethers.getContractFactory('rarity_extended_boars_cooking')).deploy(
        this.Steamed_Mushrooms.address,
        this.Grilled_Mushrooms.address,
        this.Fruit_and_Mushroom_Mix.address,
        this.Meat_and_Mushroom_Skewer.address,
        this.Gourmet_Fruit_and_Mushroom_Mix.address,
    );
    await this.BoarsCook.deployed();
    console.log("Deployed to:", this.BoarsCook.address);

    //Setting minter
    await (await this.Steamed_Mushrooms.setMinter(this.BoarsCook.address)).wait();
    await (await this.Grilled_Mushrooms.setMinter(this.BoarsCook.address)).wait();
    await (await this.Fruit_and_Mushroom_Mix.setMinter(this.BoarsCook.address)).wait();
    await (await this.Meat_and_Mushroom_Skewer.setMinter(this.BoarsCook.address)).wait();
    await (await this.Gourmet_Fruit_and_Mushroom_Mix.setMinter(this.BoarsCook.address)).wait();
    console.log("Minter setted up successfully to:", this.BoarsCook.address);

    //Verify
    await hre.run("verify:verify", {
        address: this.BoarsCook.address,
        constructorArguments: [
            this.Steamed_Mushrooms.address,
            this.Grilled_Mushrooms.address,
            this.Fruit_and_Mushroom_Mix.address,
            this.Meat_and_Mushroom_Skewer.address,
            this.Gourmet_Fruit_and_Mushroom_Mix.address,
        ],
    });
    await hre.run("verify:verify", {
        address: this.Steamed_Mushrooms.address,
        constructorArguments: [],
        contract: "contracts/meals.sol:Steamed_Mushrooms"
    });
    await hre.run("verify:verify", {
        address: this.Grilled_Mushrooms.address,
        constructorArguments: [],
        contract: "contracts/meals.sol:Grilled_Mushrooms"
    });
    await hre.run("verify:verify", {
        address: this.Fruit_and_Mushroom_Mix.address,
        constructorArguments: [],
        contract: "contracts/meals.sol:Fruit_and_Mushroom_Mix"
    });
    await hre.run("verify:verify", {
        address: this.Meat_and_Mushroom_Skewer.address,
        constructorArguments: [],
        contract: "contracts/meals.sol:Meat_and_Mushroom_Skewer"
    });
    await hre.run("verify:verify", {
        address: this.Gourmet_Fruit_and_Mushroom_Mix.address,
        constructorArguments: [],
        contract: "contracts/meals.sol:Gourmet_Fruit_and_Mushroom_Mix"
    });

    //Setting extended
    await (await this.BoarsCook.setExtended(extendedMultisig)).wait();
    console.log("Extended setted up successfully to:", extendedMultisig);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });