pragma solidity ^0.5.6;

contract MainContractOwnable{
    address private _mainContract;

    constructor(address _mainContractAddress) public {
        _mainContract = _mainContractAddress;
    }

    /**
     * @dev Throws if called by any account other than the main contract.
     */
    modifier onlyMainContract() {
        require(_isMainContract(), "The sender is not the main contract.");
        _;
    }

    /**
     * @return true if `msg.sender` is the main contract.
     */
    function _isMainContract() private view returns (bool) {
        return msg.sender == _mainContract;
    }

    /**
     * @return address of the main contract.
     */
    function mainContract() external view returns(address){
        return _mainContract;
    }
}