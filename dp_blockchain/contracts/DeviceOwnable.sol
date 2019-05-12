pragma solidity ^0.5.6;

import "./MainContractOwnable.sol";

contract DeviceOwnable is MainContractOwnable{

    struct DeviceOwnerSettings{
        address ownerAddress;
        Rights rights;
    }

    enum Rights {NONE, DELETE, WRITE_DELETE}

    mapping(uint => DeviceOwnerSettings) internal _deviceOwners;

    constructor(address _address) MainContractOwnable(_address) public {}

    /**
     * @return true if the sender is the owner of the device with the _deviceId.
     * @param _sender The sending address.
     * @param _deviceId The device id.
     */
    function _isDeviceOwner(address _sender, uint _deviceId) internal view returns (bool){
        return _sender == _deviceOwners[_deviceId].ownerAddress;
    }

    /**
     * @return true if the device has some owner.
     * @param _deviceId The device id.
     */
    function _hasDeviceOwner(uint _deviceId) internal view returns (bool){
        return ((_deviceOwners[_deviceId].ownerAddress != address(0)) && (_deviceOwners[_deviceId].rights != Rights.NONE));
    }

    /**
     * @return true if the sender can save data.
     * @param _sender The sending address.
     * @param _deviceId The device id.
     */
    function _canSaveData(address _sender, uint _deviceId) internal view returns (bool) {
        if (_deviceOwners[_deviceId].ownerAddress != address(0)){
            if(_deviceOwners[_deviceId].rights == Rights.WRITE_DELETE){
                if(_deviceOwners[_deviceId].ownerAddress != _sender){
                    return false;
                }
            }
        }
        return true;
    }

    /**
     * @dev Changes device owner. Only device owner can use.
     * @param _sender The sending address.
     * @param _deviceId The device id.
     * @param _newOwner The new owner address.
     */
    function changeDeviceOwner(address _sender, uint _deviceId, address _newOwner) public onlyMainContract{
        require(_isDeviceOwner(_sender, _deviceId), "The sender is not the device owner.");
        require(_hasDeviceOwner(_deviceId), "The device does not have any owner.");
        _deviceOwners[_deviceId].ownerAddress = _newOwner;
    }

    /**
     * @dev Changes device owner rights. Only device owner can use.
     * @param _sender The sending address.
     * @param _deviceId The device id.
     * @param _rights The rights.
     */
    function changeDeviceOwnershipRights(address _sender, uint _deviceId, uint _rights) public onlyMainContract{
        require(_isDeviceOwner(_sender, _deviceId), "The sender is not the device owner.");
        require((uint(Rights.WRITE_DELETE) >= _rights) && (_rights > 0), "The value representing rights is incorrect value.");
        _deviceOwners[_deviceId].rights = Rights(_rights);
    }

    /**
     * @return address of the device owner.
     * @param _deviceId The device id.
     */
    function getDeviceOwner(uint _deviceId) public view returns(address){
        return  _deviceOwners[_deviceId].ownerAddress;
    }
}