const { deployments, ethers } = require('hardhat');
const { expect, use } = require('chai');
const { solidity } = require('ethereum-waffle');

const RarityExtendedBoarsCook = artifacts.require("rarity_extended_boars_cooking");
const Steamed_Mushrooms = artifacts.require("Steamed_Mushrooms");
const Grilled_Mushrooms = artifacts.require("Grilled_Mushrooms");
const Fruit_and_Mushroom_Mix = artifacts.require("Fruit_and_Mushroom_Mix");
const Meat_and_Mushroom_Skewer = artifacts.require("Meat_and_Mushroom_Skewer");
const Gourmet_Fruit_and_Mushroom_Mix = artifacts.require("Gourmet_Fruit_and_Mushroom_Mix");

use(solidity);

describe("Tests", function () {
	let rarityExtendedBoarsCook;
    let erc20_Steamed_Mushrooms;
    let erc20_Grilled_Mushrooms;
    let erc20_Fruit_and_Mushroom_Mix;
    let erc20_Meat_and_Mushroom_Skewer;
    let erc20_Gourmet_Fruit_and_Mushroom_Mix;

    let     ADVENTURER = 0;
    let     SUMMMONER_ID = 0;
    const   RARITY_ADDRESS = '0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb'
    const   LOOT_MUSHROOM_ADDR = '0xcd80cE7E28fC9288e20b806ca53683a439041738';
    const   LOOT_BERRIES_ADDR = '0x9d6C92CCa7d8936ade0976282B82F921F7C50696';
    const   LOOT_WOOD_ADDR = '0xdcE321D1335eAcc510be61c00a46E6CF05d6fAA1';
    const   LOOT_MEAT_ADDR = '0x95174B2c7E08986eE44D65252E3323A782429809';

    before(async function () {
		await deployments.fixture();
		[user, anotherUser] = await ethers.getSigners();

        const   RARITY = new ethers.Contract(RARITY_ADDRESS, [
			'function next_summoner() public view returns (uint)',
			'function summon(uint _class) external',
			'function setApprovalForAll(address operator, bool _approved) external',
		], user);
		ADVENTURER = Number(await RARITY.next_summoner());
		await (await RARITY.summon(1)).wait();

        await mintERC20(LOOT_MUSHROOM_ADDR, ADVENTURER, 100);
        await mintERC20(LOOT_BERRIES_ADDR, ADVENTURER, 100);
        await mintERC20(LOOT_WOOD_ADDR, ADVENTURER, 100);
        await mintERC20(LOOT_MEAT_ADDR, ADVENTURER, 100);

        erc20_Steamed_Mushrooms = await Steamed_Mushrooms.new();
        erc20_Grilled_Mushrooms = await Grilled_Mushrooms.new();
        erc20_Fruit_and_Mushroom_Mix = await Fruit_and_Mushroom_Mix.new();
        erc20_Meat_and_Mushroom_Skewer = await Meat_and_Mushroom_Skewer.new();
        erc20_Gourmet_Fruit_and_Mushroom_Mix = await Gourmet_Fruit_and_Mushroom_Mix.new();

		rarityExtendedBoarsCook = await RarityExtendedBoarsCook.new(
            erc20_Steamed_Mushrooms.address,
            erc20_Grilled_Mushrooms.address,
            erc20_Fruit_and_Mushroom_Mix.address,
            erc20_Meat_and_Mushroom_Skewer.address,
            erc20_Gourmet_Fruit_and_Mushroom_Mix.address,
        )
        await erc20_Steamed_Mushrooms.setMinter(rarityExtendedBoarsCook.address);
        await erc20_Grilled_Mushrooms.setMinter(rarityExtendedBoarsCook.address);
        await erc20_Fruit_and_Mushroom_Mix.setMinter(rarityExtendedBoarsCook.address);
        await erc20_Meat_and_Mushroom_Skewer.setMinter(rarityExtendedBoarsCook.address);
        await erc20_Gourmet_Fruit_and_Mushroom_Mix.setMinter(rarityExtendedBoarsCook.address);

        SUMMMONER_ID = Number(await rarityExtendedBoarsCook.SUMMMONER_ID());
    });

	it('should be possible to get the name of the contract', async function() {
		const	name = await rarityExtendedBoarsCook.name();
		await	expect(name).to.be.equal('Rarity Extended Boars Cook');
	});

	it('should not be possible to cook an unknown recipe', async function() {
		await	expect(rarityExtendedBoarsCook.cook(ADVENTURER, 0, ADVENTURER)).to.be.revertedWith(`!recipe`);
		await	expect(rarityExtendedBoarsCook.cook(ADVENTURER, 6, ADVENTURER)).to.be.revertedWith(`!recipe`);
	});

	it('should not be possible to cook without approval', async function() {
		await	expect(rarityExtendedBoarsCook.cook(ADVENTURER, 1, ADVENTURER)).to.be.reverted;
	});

	it('should not be possible to cook for another adventurer', async function() {
		await	expect(rarityExtendedBoarsCook.cook(32, 1, ADVENTURER)).to.be.revertedWith(`!owner`);
	});

	it('should be possible to approve all the erc20', async function() {
        const   ERC20ABI = ['function approve(uint from, uint spender, uint amount) external returns (bool)'];
        const    LOOT_MUSHROOM_CONTRACT = new ethers.Contract(LOOT_MUSHROOM_ADDR, ERC20ABI, user);
        const    LOOT_BERRIES_CONTRACT = new ethers.Contract(LOOT_BERRIES_ADDR, ERC20ABI, user);
        const    LOOT_WOOD_CONTRACT = new ethers.Contract(LOOT_WOOD_ADDR, ERC20ABI, user);
        const    LOOT_MEAT_CONTRACT = new ethers.Contract(LOOT_MEAT_ADDR, ERC20ABI, user);

        {
            const   tx = await LOOT_MUSHROOM_CONTRACT.approve(ADVENTURER, SUMMMONER_ID, 100);
            const   receipt = await tx.wait();
            expect(receipt.status).to.be.equal(1);
        }
        {
            const   tx = await LOOT_BERRIES_CONTRACT.approve(ADVENTURER, SUMMMONER_ID, 100);
            const   receipt = await tx.wait();
            expect(receipt.status).to.be.equal(1);
        }
        {
            const   tx = await LOOT_WOOD_CONTRACT.approve(ADVENTURER, SUMMMONER_ID, 100);
            const   receipt = await tx.wait();
            expect(receipt.status).to.be.equal(1);
        }
        {
            const   tx = await LOOT_MEAT_CONTRACT.approve(ADVENTURER, SUMMMONER_ID, 100);
            const   receipt = await tx.wait();
            expect(receipt.status).to.be.equal(1);
        }
	});

	it('should be possible to cook all the receipt a few times', async function() {
		await	expect(rarityExtendedBoarsCook.cook(ADVENTURER, 1, ADVENTURER)).not.to.be.reverted;
		await	expect(rarityExtendedBoarsCook.cook(ADVENTURER, 2, ADVENTURER)).not.to.be.reverted;
		await	expect(rarityExtendedBoarsCook.cook(ADVENTURER, 3, ADVENTURER)).not.to.be.reverted;
		await	expect(rarityExtendedBoarsCook.cook(ADVENTURER, 4, ADVENTURER)).not.to.be.reverted;
		await	expect(rarityExtendedBoarsCook.cook(ADVENTURER, 5, ADVENTURER)).not.to.be.reverted;
		await	expect(rarityExtendedBoarsCook.cook(ADVENTURER, 5, ADVENTURER)).not.to.be.reverted;
		await	expect(rarityExtendedBoarsCook.cook(ADVENTURER, 4, ADVENTURER)).not.to.be.reverted;
		await	expect(rarityExtendedBoarsCook.cook(ADVENTURER, 3, ADVENTURER)).not.to.be.reverted;
		await	expect(rarityExtendedBoarsCook.cook(ADVENTURER, 2, ADVENTURER)).not.to.be.reverted;
		await	expect(rarityExtendedBoarsCook.cook(ADVENTURER, 1, ADVENTURER)).not.to.be.reverted;
		await	expect(rarityExtendedBoarsCook.cook(ADVENTURER, 1, ADVENTURER)).not.to.be.reverted;
		await	expect(rarityExtendedBoarsCook.cook(ADVENTURER, 2, ADVENTURER)).not.to.be.reverted;
		await	expect(rarityExtendedBoarsCook.cook(ADVENTURER, 3, ADVENTURER)).not.to.be.reverted;
		await	expect(rarityExtendedBoarsCook.cook(ADVENTURER, 4, ADVENTURER)).not.to.be.reverted;
		await	expect(rarityExtendedBoarsCook.cook(ADVENTURER, 5, ADVENTURER)).not.to.be.reverted;
		await	expect(rarityExtendedBoarsCook.cook(ADVENTURER, 5, ADVENTURER)).not.to.be.reverted;
		await	expect(rarityExtendedBoarsCook.cook(ADVENTURER, 4, ADVENTURER)).not.to.be.reverted;
		await	expect(rarityExtendedBoarsCook.cook(ADVENTURER, 3, ADVENTURER)).not.to.be.reverted;
		await	expect(rarityExtendedBoarsCook.cook(ADVENTURER, 2, ADVENTURER)).not.to.be.reverted;
		await	expect(rarityExtendedBoarsCook.cook(ADVENTURER, 1, ADVENTURER)).not.to.be.reverted;
	});

});

async function    mintERC20(address, to, amount, slot) {
    const toBytes32 = (bn) => {
        return ethers.utils.hexlify(ethers.utils.zeroPad(bn.toHexString(), 32));
    };
    const setStorageAt = async (address, index, value) => {
        await ethers.provider.send("hardhat_setStorageAt", [address, index, value]);
        await ethers.provider.send("evm_mine", []); // Just mines to the next block
    };

    const SLOT = 8;
    const index = ethers.utils.solidityKeccak256(
        ["uint", "uint"],
        [to, SLOT]
    );
    await setStorageAt(
        address,
        index.toString(),
        toBytes32(ethers.BigNumber.from(amount)).toString()
    );
}
async function balanceOf(tokenAddress, user) {
    const abi = ['function balanceOf(uint) external view returns (uint)'];
    const contract = new ethers.Contract(tokenAddress, abi, ethers.provider);
    return (await contract.balanceOf(user)).toString();
}
