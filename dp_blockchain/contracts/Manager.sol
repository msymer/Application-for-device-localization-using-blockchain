pragma solidity ^0.5.6;

import "./Manageable.sol";

contract Manager is Manageable{

    string public description;
    address public processAddress;
    mapping(uint => uint) public speeds;
    BackgroundProcessInterface internal _backgroundProcess;

    enum SpeedType {S1, S2, S3, S4, S5}

    event Log(address indexed adminAddress, string indexed message);
    event DescriptionChanged(address indexed adminAddress);
    event ProcessContractAddressChanged(address indexed adminAddress, address indexed newAddress);
    event SpeedChanged(address indexed adminAddress, SpeedType indexed speedType, uint indexed newValue);

    constructor() internal{
        speeds[0] = 20;
        speeds[1] = 70;
        speeds[2] = 200;
        speeds[3] = 400;
        speeds[4] = 1200;
    }

    /** 
    *@dev Sets speed of a speed type.
    *@param _speedType The speed type.
    *@param _speedValue The speed value.
    */
    function setSpeed(SpeedType _speedType, uint _speedValue) public onlyAdmin{
        require(_speedValue > 0, "Speed value can not be 0.");
        if(_speedType != SpeedType.S1){
            require(speeds[uint(_speedType) - 1] <= _speedValue, "The speed value is smaller than a speed value of the slower speed type.");
        }
        if(_speedType != SpeedType.S5){
            require(speeds[uint(_speedType) + 1] >= _speedValue, "The speed value is bigger than a speed value of the faster speed type.");
        }
        speeds[uint(_speedType)] = _speedValue;
        emit SpeedChanged(msg.sender, _speedType, speeds[uint(_speedType)]);
    }

    /** 
    *@dev Logs a message to the events. Only admin can call.
    *@param _message The message.
    */
    function log(string memory _message) public onlyAdmin{
        require(bytes(_message).length > 0, "The message is empty.");
        emit Log(msg.sender, _message);
    }

    /** 
    *@dev Sets a new process contract address. Only admin can call.
    *@param _newAddress The new address.
    */
    function setProcessAddress(address _newAddress) public onlyAdmin{
        require(_newAddress != address(0), "The new process address is empty.");
        processAddress = _newAddress;
        _backgroundProcess = BackgroundProcessInterface(processAddress);
        emit ProcessContractAddressChanged(msg.sender, processAddress);
    }
    
    /** 
    *@dev Sets the contract description. Only admin can call.
    *@param _newDescription The new description.
    */
    function setDescription(string memory _newDescription) public onlyAdmin{
        require(bytes(_newDescription).length > 0, "The new description is empty.");
        description = _newDescription;
        emit DescriptionChanged(msg.sender);
    }
}

contract BackgroundProcessInterface{
    function checkInputData(address _sender, uint _speed, uint _deviceId, int32 _latitude, int32 _longitude, uint _time) public view returns(bool);
    function checkInputData(address _sender, uint _speed, int32 _latitude1, int32 _longitude1, uint _time1, int32 _latitude2, int32 _longitude2, uint _time2) public pure returns(bool);
    function getData(address _sender, uint _deviceId, uint _index, uint _dateFrom, uint _dateTo, uint _speed) public view returns(uint, int32, int32, string memory);
    function getData(address _sender, uint _deviceId, uint _index, uint _dateFrom, uint _dateTo) public view returns(uint, int32, int32, string memory);
    function saveData(address _sender, uint _deviceId, int32 _latitude, int32 _longitude, uint _time, string memory _note) public;
    function saveData(address _sender, uint _speed, uint _deviceId, int32 _latitude, int32 _longitude, uint _time, string memory _note) public;
    function deleteData(address _sender, uint _deviceId, uint _localizationTime) public;
    function addDeviceOwner(address _sender, uint _deviceId) public;
    function changeDeviceOwner(address _sender, uint _deviceId, address _newOwner) public;
    function changeDeviceOwnershipRights(address _sender, uint _deviceId, uint _rights) public;
    function getDeviceOwner(uint _deviceId) public view returns(address);
    function getDataCount(address _sender, uint _deviceId, uint _dateFrom, uint _dateTo) public view returns(uint);
    function getDataCount(address _sender, uint _deviceId, uint _dateFrom, uint _dateTo, uint _speed) public view returns(uint);
}