// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./interfaces/IRarity.sol";
import "./interfaces/IrERC20.sol";
import "./onlyExtended.sol";

contract rarity_extended_boars_cooking is OnlyExtended {
    string public constant name = "Rarity Extended Boars Cook";
    string public constant symbol = "Cook (1)";
    uint256 public constant GOLD_COST = 4e18;
    uint public immutable SUMMMONER_ID;
    uint public multiplier = 1;

    IRarity constant _rm = IRarity(0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb);
    IrERC20 constant _gold = IrERC20(0x2069B76Afe6b734Fb65D1d099E7ec64ee9CC76B2);
    IrERC20 constant _mushroom = IrERC20(0xcd80cE7E28fC9288e20b806ca53683a439041738);
    IrERC20 constant _berries = IrERC20(0x9d6C92CCa7d8936ade0976282B82F921F7C50696);
    IrERC20 constant _wood = IrERC20(0xdcE321D1335eAcc510be61c00a46E6CF05d6fAA1);
    IrERC20 constant _meat = IrERC20(0x95174B2c7E08986eE44D65252E3323A782429809);

    IrERC20 public steamedMushroom;
    IrERC20 public grilledMushroom;
    IrERC20 public fruitAndMushroomMix;
    IrERC20 public mushroomAndMeatSkewer;
    IrERC20 public gourmetFruitAndMushroom;

    event SetMultiplier(uint multiplier);

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

    function    setMultiplier(uint _multiplier) public onlyExtended() {
        multiplier = _multiplier;
        emit SetMultiplier(_multiplier);
    }

    function approveAll(uint _summoner) external {
        require(_isApprovedOrOwner(_summoner), "!owner");
        require(_rm.getApproved(_summoner) == address(this), "!approved");
        _gold.approve(_summoner, SUMMMONER_ID, type(uint256).max);
        _mushroom.approve(_summoner, SUMMMONER_ID, type(uint256).max);
        _berries.approve(_summoner, SUMMMONER_ID, type(uint256).max);
        _wood.approve(_summoner, SUMMMONER_ID, type(uint256).max);
        _meat.approve(_summoner, SUMMMONER_ID, type(uint256).max);
    }

    function cook(uint _summoner, uint8 _recipe, uint _receiver) external {
        require(_isApprovedOrOwner(_summoner), "!owner");
        require(_recipe >= 1 && _recipe <= 5, "!recipe");
        require(_gold.transferFrom(SUMMMONER_ID, _summoner, SUMMMONER_ID, GOLD_COST), "!gold");

        if (_recipe == 1) {
            require(_mushroom.transferFrom(SUMMMONER_ID, _summoner, SUMMMONER_ID, 2 * multiplier), "!approval");
            
            steamedMushroom.mint(_receiver, 1);
        } else if (_recipe == 2) {
            require(_mushroom.transferFrom(SUMMMONER_ID, _summoner, SUMMMONER_ID, 2 * multiplier), "!approval");
            require(_wood.transferFrom(SUMMMONER_ID, _summoner, SUMMMONER_ID, 1 * multiplier), "!approval");

            grilledMushroom.mint(_receiver, 1);
        } else if (_recipe == 3) {
            require(_mushroom.transferFrom(SUMMMONER_ID, _summoner, SUMMMONER_ID, 2 * multiplier), "!approval");
            require(_berries.transferFrom(SUMMMONER_ID, _summoner, SUMMMONER_ID, 2 * multiplier), "!approval");

            fruitAndMushroomMix.mint(_receiver, 1);
        } else if (_recipe == 4) {
            require(_mushroom.transferFrom(SUMMMONER_ID, _summoner, SUMMMONER_ID, 2 * multiplier), "!approval");
            require(_meat.transferFrom(SUMMMONER_ID, _summoner, SUMMMONER_ID, 1 * multiplier), "!approval");

            mushroomAndMeatSkewer.mint(_receiver, 1);
        } else if (_recipe == 5) {
            require(_mushroom.transferFrom(SUMMMONER_ID, _summoner, SUMMMONER_ID, 2 * multiplier), "!approval");
            require(_berries.transferFrom(SUMMMONER_ID, _summoner, SUMMMONER_ID, 2 * multiplier), "!approval");
            require(_meat.transferFrom(SUMMMONER_ID, _summoner, SUMMMONER_ID, 1 * multiplier), "!approval");

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