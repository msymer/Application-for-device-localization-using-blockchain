pragma solidity ^0.5.6;

import "./Manager.sol";
import "./TrackerBackgroundProcesses.sol";

contract Tracker is Manager{

    event DataSaved(address indexed sender);
    event DataDeleted(address indexed sender, string deviceId, uint indexed locationTime);
    event DeviceOwnerChanged(address indexed sender, string deviceId, address indexed newOwner);
    event DeviceOwnershipRightsChanged(address indexed sender, string deviceId, uint indexed rights);

    function _originalDeviceIdToNumber(string memory _deviceId) private pure returns(uint){
        require(bytes(_deviceId).length > 0, "The device id is empty.");
        return uint(keccak256(abi.encodePacked(_deviceId)));
    }

    function getData(string memory _deviceId, uint _index, uint _dateFrom, uint _dateTo) public view returns(uint, int32, int32, string memory) {
        uint deviceId = _originalDeviceIdToNumber(_deviceId);
        return _backgroundProcess.getData(msg.sender, deviceId, _index, _dateFrom, _dateTo);
    }

    function getDataWithSpeedCheck(string memory _deviceId, uint _index, uint _dateFrom, uint _dateTo, uint _speedType) public view returns(uint, int32, int32, string memory) {
        if(_speedType >=5){
            return (0,0,0,"");
        }
        uint deviceId = _originalDeviceIdToNumber(_deviceId);
        uint speed = speeds[_speedType];
        return _backgroundProcess.getData(msg.sender, deviceId, _index, _dateFrom, _dateTo, speed);
    }

    function checkInputData(string memory _deviceId, int32 _latitude, int32 _longitude, uint _time, uint _speedType) public view returns(bool){
        if(_speedType >=5){
            return false;
        }
        uint deviceId = _originalDeviceIdToNumber(_deviceId);
        uint speed = speeds[_speedType];
        return _backgroundProcess.checkInputData(msg.sender, speed, deviceId, _latitude, _longitude, _time);
    }

    function checkOutsideInputData(uint _speedType, int32 _latitude1, int32 _longitude1, uint _time1, int32 _latitude2, int32 _longitude2, uint _time2) public view returns(bool){
        if(_speedType >=5){
            return false;
        }
        uint speed = speeds[_speedType];
        return _backgroundProcess.checkInputData(msg.sender, speed, _latitude1, _longitude1, _time1, _latitude2, _longitude2, _time2);
    }

    function saveData(string memory _deviceId, int32 _latitude, int32 _longitude, uint _time, string memory _note) public{
        uint deviceId = _originalDeviceIdToNumber(_deviceId);
        _backgroundProcess.saveData(msg.sender, deviceId, _latitude, _longitude, _time, _note);
        emit DataSaved(msg.sender);
    }

    function saveDataWithSpeedCheck(string memory _deviceId, uint _speedType, int32 _latitude, int32 _longitude, uint _time, string memory _note) public{
        require(_speedType < 5, "Incorrect speed type.");
        uint deviceId = _originalDeviceIdToNumber(_deviceId);
        uint speed = speeds[_speedType];
        _backgroundProcess.saveData(msg.sender, speed, deviceId, _latitude, _longitude, _time, _note);
        emit DataSaved(msg.sender);
    }

    function deleteData(string memory _deviceId, uint _localizationTime) public {
        uint deviceId = _originalDeviceIdToNumber(_deviceId);
        _backgroundProcess.deleteData(msg.sender, deviceId, _localizationTime);
        emit DataDeleted(msg.sender, _deviceId, _localizationTime);
    }

    function addDeviceOwner(string memory _deviceId) public{
        uint deviceId = _originalDeviceIdToNumber(_deviceId);
        _backgroundProcess.addDeviceOwner(msg.sender, deviceId);
        emit DeviceOwnerChanged(msg.sender, _deviceId, msg.sender);
    }

    function changeDeviceOwner(string memory _deviceId, address _newOwner) public {
        uint deviceId = _originalDeviceIdToNumber(_deviceId);
        _backgroundProcess.changeDeviceOwner(msg.sender, deviceId, _newOwner);
        emit DeviceOwnerChanged(msg.sender, _deviceId, _newOwner);
    }

    function changeDeviceOwnershipRights(string memory _deviceId, uint _rights) public {
        uint deviceId = _originalDeviceIdToNumber(_deviceId);
        _backgroundProcess.changeDeviceOwnershipRights(msg.sender, deviceId, _rights);
        emit DeviceOwnershipRightsChanged(msg.sender, _deviceId, _rights);

    }

    function getDeviceOwner(string memory _deviceId) public view returns(address) {
        uint deviceId = _originalDeviceIdToNumber(_deviceId);
        return _backgroundProcess.getDeviceOwner(deviceId);
    }

    function getDataCount(string memory _deviceId, uint _dateFrom, uint _dateTo) public view returns(uint) {
        uint deviceId = _originalDeviceIdToNumber(_deviceId);
        return _backgroundProcess.getDataCount(msg.sender, deviceId, _dateFrom, _dateTo);
    }

    function getDataCountWithSpeedCheck(string memory _deviceId, uint _dateFrom, uint _dateTo, uint _speedType) public view returns(uint) {
        if(_speedType >=5){
            return 0;
        }
        uint deviceId = _originalDeviceIdToNumber(_deviceId);
        uint speed = speeds[_speedType];
        return _backgroundProcess.getDataCount(msg.sender, deviceId, _dateFrom, _dateTo, speed);
    }
}
