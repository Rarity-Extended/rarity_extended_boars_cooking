// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/access/AccessControl.sol";

interface IRarity {
    function getApproved(uint) external view returns (address);
    function ownerOf(uint) external view returns (address);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

abstract contract OnlyExtended {
    address public extended;
    address public pendingExtended;

    constructor() {
        extended = msg.sender;
    }

    modifier onlyExtended() {
        require(msg.sender == extended, "!owner");
        _;
    }
    modifier onlyPendingExtended() {
		require(msg.sender == pendingExtended, "!authorized");
		_;
	}

    /*******************************************************************************
	**	@notice
	**		Nominate a new address to use as Extended.
	**		The change does not go into effect immediately. This function sets a
	**		pending change, and the management address is not updated until
	**		the proposed Extended address has accepted the responsibility.
	**		This may only be called by the current Extended address.
	**	@param _extended The address requested to take over the role.
	*******************************************************************************/
    function setExtended(address _extended) public onlyExtended() {
		pendingExtended = _extended;
	}


	/*******************************************************************************
	**	@notice
	**		Once a new extended address has been proposed using setExtended(),
	**		this function may be called by the proposed address to accept the
	**		responsibility of taking over the role for this contract.
	**		This may only be called by the proposed Extended address.
	**	@dev
	**		setExtended() should be called by the existing extended address,
	**		prior to calling this function.
	*******************************************************************************/
    function acceptExtended() public onlyPendingExtended() {
		extended = msg.sender;
	}
    
}

abstract contract rERC20 is AccessControl, OnlyExtended {
    IRarity constant rm = IRarity(0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb);
    uint8 public constant decimals = 18;

    string public name;
    string public symbol;
    uint public totalSupply = 0;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor(string memory _name, string memory _symbol) OnlyExtended() {
        name = _name;
        symbol = _symbol;
    }

    /*******************************************************************************
	**	@notice
	**		For a contract to be able to mint tokens, it must first be added as a
    **		minter. This is done by calling the `setMinter` function.
    **      The `setMinter` function must be called by the owner of the contract,
    **      aka Extended.
	**	@param _minter The address to add as a Minter.
	*******************************************************************************/
    function setMinter(address _minter) external onlyExtended() {
        _setupRole(MINTER_ROLE, _minter);
    }

    /*******************************************************************************
	**	@notice
	**		For some security reason, the owner should be able to remove a minter.
    **      The `unsetMinter` function must be called by the owner of the contract,
    **      aka Extended.
	**	@param _minter The address to remove as a Minter.
	*******************************************************************************/
    function unsetMinter(address _minter) external onlyExtended() {
        revokeRole(MINTER_ROLE, _minter);
    }

    mapping(uint => mapping (uint => uint)) public allowance;
    mapping(uint => uint) public balanceOf;

    event Transfer(uint indexed from, uint indexed to, uint amount);
    event Approval(uint indexed from, uint indexed to, uint amount);
    event Burn(uint indexed from, uint amount);
    event Mint(uint indexed to, uint amount);

    function _isApprovedOrOwner(uint _summoner) internal view returns (bool) {
        return rm.getApproved(_summoner) == msg.sender || rm.ownerOf(_summoner) == msg.sender || rm.isApprovedForAll(rm.ownerOf(_summoner), msg.sender);
    }

    function mint(uint to, uint amount) external onlyRole(MINTER_ROLE) {
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Mint(to, amount);
    }

    // You can only burn your own tokens
    function burn(uint from, uint amount) external {
        require(_isApprovedOrOwner(from), "!owner");
        totalSupply -= amount;
        balanceOf[from] -= amount;
        emit Burn(from, amount);
    }

    function approve(uint from, uint spender, uint amount) external returns (bool) {
        require(_isApprovedOrOwner(from), "!owner");
        allowance[from][spender] = amount;

        emit Approval(from, spender, amount);
        return true;
    }

    function transfer(uint from, uint to, uint amount) external returns (bool) {
        require(_isApprovedOrOwner(from), "!owner");
        _transferTokens(from, to, amount);
        return true;
    }

    function transferFrom(uint executor, uint from, uint to, uint amount) external returns (bool) {
        require(_isApprovedOrOwner(executor), "!owner");
        uint spender = executor;
        uint spenderAllowance = allowance[from][spender];

        if (spender != from && spenderAllowance != type(uint).max) {
            uint newAllowance = spenderAllowance - amount;
            allowance[from][spender] = newAllowance;

            emit Approval(from, spender, newAllowance);
        }

        _transferTokens(from, to, amount);
        return true;
    }

    function _transferTokens(uint from, uint to, uint amount) internal {
        balanceOf[from] -= amount;
        balanceOf[to] += amount;

        emit Transfer(from, to, amount);
    }
}

contract Steamed_Mushrooms is rERC20 {
    constructor() rERC20("Steamed Mushrooms", "Steamed Mushrooms - (Meal)") {}
}

contract Grilled_Mushrooms is rERC20 {
    constructor() rERC20("Grilled Mushrooms", "Grilled Mushrooms - (Meal)") {}
}

contract Fruit_and_Mushroom_Mix is rERC20 {
    constructor() rERC20("Fruit and Mushroom Mix", "Fruit and Mushroom Mix - (Meal)") {}
}

contract Meat_and_Mushroom_Skewer is rERC20 {
    constructor() rERC20("Meat and Mushroom Skewer", "Meat and Mushroom Skewer - (Meal)") {}
}

contract Gourmet_Fruit_and_Mushroom_Mix is rERC20 {
    constructor() rERC20("Gourmet Fruit and Mushroom Mix", "Gourmet Fruit and Mushroom Mix - (Meal)") {}
}
