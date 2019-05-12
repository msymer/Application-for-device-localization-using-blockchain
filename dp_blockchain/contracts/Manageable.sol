pragma solidity ^0.5.6;

import "./Ownable.sol";
/**
 * @title Manageable
 * @dev The Manageable contract has an owner address and admin addresses, and provides authorization control functions.
 */
contract Manageable is Ownable{

    mapping(address => bool) private _admins;
    address[] private _adminAddresses;

    event AdminAdded(address indexed initAdmin, address indexed newAdmin);
    event AdminRemoved(address indexed initAdmin, address indexed removedAdmin);

    /**
     * @return addresses of admins.
     */
    function admins() public view returns (address[] memory) {
        return _adminAddresses;
    }

    /**
     * @dev Throws if called by any account other than an admin or the owner.
     */
    modifier onlyAdmin() {
        require(isAdmin(), "Sender is not an admin of the contract.");
        _;
    }

    /**
     * @return True if `msg.sender` is the owner or an admin of the contract.
     */
    function isAdmin() public view returns (bool) {
        return (msg.sender == owner()) || (_admins[msg.sender] == true);
    }

    /**
     * @dev Removes adminship from an address.
     * @param _removedAdmin The address to remove adminship from.
     */
    function _removeAdmin(address _removedAdmin) internal {
        require(_removedAdmin != address(0), "Removed address is emtpy.");
        require(_admins[_removedAdmin] == true, "Removed address is not an admin.");
        emit AdminRemoved(msg.sender, _removedAdmin);
        delete _admins[_removedAdmin];
        uint index = 0;
        for(uint i = 0; i < _adminAddresses.length; i++){
            if(_adminAddresses[i] == _removedAdmin){
                index = i;
                break;
            }
        }
        delete  _adminAddresses[index];
        _adminAddresses[index] = _adminAddresses[_adminAddresses.length-1];
        delete  _adminAddresses[_adminAddresses.length-1];
        _adminAddresses.length--;
    }

    /**
     * @dev Removes adminship from an address.
     * @param _removedAdmin The address to remove adminship from.
     */
    function removeAdmin(address _removedAdmin) public onlyAdmin {
        _removeAdmin(_removedAdmin);
    }

    /**
     * @dev Adds a new admin.
     * @param _newAdmin The address of the new admin.
     */
    function _addAdmin(address _newAdmin) internal {
        require(_newAdmin != address(0), "Removed address is emtpy.");
        require(_admins[_newAdmin] == false, "The address is already an admin.");
        emit AdminAdded(msg.sender, _newAdmin);
        _admins[_newAdmin] = true;
        _adminAddresses.push(_newAdmin);
    }

    /**
     * @dev Adds a new admin.
     * @param _newAdmin The address to the new admin.
     */
     function addAdmin(address _newAdmin) public onlyAdmin {
         _addAdmin(_newAdmin);
     }
}