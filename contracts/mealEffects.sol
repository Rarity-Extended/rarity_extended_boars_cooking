// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./interfaces/IRarity.sol";
import "./interfaces/IrERC20.sol";
import "./onlyExtended.sol";

contract rarity_extended_boars_cooking is OnlyExtended {
    string public constant name = "Rarity Extended Boars Cook";
    string public constant symbol = "Cook (1)";
    uint public immutable SUMMMONER_ID;

    IRarity constant _rm = IRarity(0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb);
    IrERC20 constant _mushroom = IrERC20(0xcd80cE7E28fC9288e20b806ca53683a439041738);
    IrERC20 constant _berries = IrERC20(0x9d6C92CCa7d8936ade0976282B82F921F7C50696);
    IrERC20 constant _wood = IrERC20(0xdcE321D1335eAcc510be61c00a46E6CF05d6fAA1);
    IrERC20 constant _meat = IrERC20(0x95174B2c7E08986eE44D65252E3323A782429809);

    IrERC20 public steamedMushroom;
    IrERC20 public grilledMushroom;
    IrERC20 public fruitAndMushroomMix;
    IrERC20 public mushroomAndMeatSkewer;
    IrERC20 public gourmetFruitAndMushroom;

    constructor( 
        address _steamedMushroom,
        address _grilledMushroom,
        address _fruitAndMushroomMix,
        address _mushroomAndMeatSkewer,
        address _gourmetFruitAndMushroom
    ) OnlyExtended() {
        SUMMMONER_ID = _rm.next_summoner();
        _rm.summon(2);

        steamedMushroom = IrERC20(_steamedMushroom);
        grilledMushroom = IrERC20(_grilledMushroom);
        fruitAndMushroomMix = IrERC20(_fruitAndMushroomMix);
        mushroomAndMeatSkewer = IrERC20(_mushroomAndMeatSkewer);
        gourmetFruitAndMushroom = IrERC20(_gourmetFruitAndMushroom);
    }

    function cook(uint _summoner, uint8 _recipe, uint _receiver) external {
        require(_isApprovedOrOwner(_summoner), "!owner");
        require(_recipe >= 1 && _recipe <= 5, "!recipe");
        if (_recipe == 1) {
            require(_mushroom.transferFrom(SUMMMONER_ID, _summoner, SUMMMONER_ID, 2), "!approval");
            
            steamedMushroom.mint(_receiver, 1);
        } else if (_recipe == 2) {
            require(_mushroom.transferFrom(SUMMMONER_ID, _summoner, SUMMMONER_ID, 2), "!approval");
            require(_wood.transferFrom(SUMMMONER_ID, _summoner, SUMMMONER_ID, 1), "!approval");

            grilledMushroom.mint(_receiver, 1);
        } else if (_recipe == 3) {
            require(_mushroom.transferFrom(SUMMMONER_ID, _summoner, SUMMMONER_ID, 2), "!approval");
            require(_berries.transferFrom(SUMMMONER_ID, _summoner, SUMMMONER_ID, 2), "!approval");

            fruitAndMushroomMix.mint(_receiver, 1);
        } else if (_recipe == 4) {
            require(_mushroom.transferFrom(SUMMMONER_ID, _summoner, SUMMMONER_ID, 2), "!approval");
            require(_meat.transferFrom(SUMMMONER_ID, _summoner, SUMMMONER_ID, 1), "!approval");

            mushroomAndMeatSkewer.mint(_receiver, 1);
        } else if (_recipe == 5) {
            require(_mushroom.transferFrom(SUMMMONER_ID, _summoner, SUMMMONER_ID, 2), "!approval");
            require(_berries.transferFrom(SUMMMONER_ID, _summoner, SUMMMONER_ID, 2), "!approval");
            require(_meat.transferFrom(SUMMMONER_ID, _summoner, SUMMMONER_ID, 1), "!approval");

            gourmetFruitAndMushroom.mint(_receiver, 1);
        }
    }

    function _isApprovedOrOwner(uint _summoner) internal view returns (bool) {
        return (
            _rm.getApproved(_summoner) == msg.sender ||
            _rm.ownerOf(_summoner) == msg.sender ||
            _rm.isApprovedForAll(_rm.ownerOf(_summoner), msg.sender)
        );
    }
}