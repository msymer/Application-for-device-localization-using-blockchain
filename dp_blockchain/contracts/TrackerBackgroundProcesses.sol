pragma solidity ^0.5.6;

import "./DeviceOwnable.sol";
import "./DistanceCalculator.sol";

contract TrackerBackgroundProcesses is DeviceOwnable, DistanceCalculator{

    struct LocationData{
        int32 latitude;
        int32 longitude;
        uint time;
        string note;
    }

    constructor(address _address) DeviceOwnable(_address) public {}

    mapping(uint => LocationData[]) private _deviceData;
    
    /**
     * All coordinates in this contract are a int type, but last 5 numbers represent decimals. 
     * Example: 2000000 represents 20.00000, 5000 represents 0.05000
     */

    /**
     * @return true if a device with the _deviceId has some saved data.
     */
    function _hasData(uint _deviceId) private view returns(bool){
        return (_deviceData[_deviceId].length > 0);
    }

    /** 
    *@dev Checks if an input data are correct based on the last saved location.
    *@param _sender The sending address.
    *@param _speed The limit speed for a device movement. Everything faster is concidered as an incorrect data. Speed is in km/h.
    *@param _deviceId The device id;
    *@param _latitude The input latitude.
    *@param _longitude The input longitude.
    *@param _time The input time of location.
    *@return true if is correct
    */
    function checkInputData(address _sender, uint _speed, uint _deviceId, int32 _latitude, int32 _longitude, uint _time) public view returns(bool) {
        if(!((_time >= (now - 172800)) && (_time < now + 600))){
            return false;
        }
        if(!_hasData(_deviceId)){
            return true;
        }
        LocationData memory lastData = _deviceData[_deviceId][_deviceData[_deviceId].length-1];
        if(lastData.time != 0){
            return checkInputData(_sender, _speed, lastData.latitude, lastData.longitude, lastData.time, _latitude, _longitude, _time);
        }
        return true;
    }

    /** 
    *@dev Checks if two points has a correct location.
    *@param _sender The sending address.
    *@param _speed The limit speed for a device movement. Everything faster is concidered as an incorrect data. Speed is in km/h.
    *@param _latitude1 The latitude of the first point.
    *@param _longitude1 The longitude of the first point.
    *@param _time1 The time of the first point.
    *@param _latitude2 The latitude of the second point.
    *@param _longitude2 The longitude of the second point.
    *@param _time2 The time of the second point.
    *@return true if is correct
    */
    function checkInputData(address _sender, uint _speed, int32 _latitude1, int32 _longitude1, uint _time1, int32 _latitude2, int32 _longitude2, uint _time2) public view returns(bool) {
        if(!((_time2 >= (now - 172800)) && (_time2 < now + 600))){
            return false;
        }
        if(_time1 > _time2){
            return false;
        }
        if((_time1 == _time2) && ((_latitude1 != _latitude2) || (_longitude1 != _longitude2))){
            return false;
        }
        uint speed = _calculateSpeed(_latitude1, _longitude1, _time1, _latitude2, _longitude2, _time2);
        if(_speed >= speed){
            return true;
        }else{
            uint speed2 = _calculateSpeed2(_latitude1, _longitude1, _time1, _latitude2, _longitude2, _time2) / 1000;
            return (_speed >= speed2);
        }
    }

    /** 
    *@dev Retrieves device data based on the _deviceId and filters it by the _dateFrom and the _dateTo. If the _dateTo is 0, returns data up to now. Because solidity can not return array of structs, the function returns only one location data per call. Use the _index parameter to specific index of the wanted data.
    *@param _sender The sending address.
    *@param _deviceId The device id;
    *@param _index The index of the wanted data.
    *@param _dateFrom The firt acceptable date for the filter.
    *@param _dateTo The last acceptable date for the filter.
    *@param _speed The maximal acceptable speed for the filter.
    *@return time, latitude, longitude, note. If is something wrong or no data, returns 0,0,0,"".
    */
    function getData(address _sender, uint _deviceId, uint _index, uint _dateFrom, uint _dateTo, uint _speed) public view returns(uint, int32, int32, string memory) {
        if(!_hasData(_deviceId)){
            return (0,0,0,"");
        }
        if(_speed == 0){
            return (0,0,0,"");
        }
        LocationData[] memory deviceData = _deviceData[_deviceId];
        uint actualIndex = 0;
        uint dateTo = _dateTo;
        if (_dateTo == 0){
            dateTo = now;
        }
        for(uint i = 0; i < deviceData.length; i++){
            require(deviceData[i].time <= dateTo, "The data not found. Try to change the date filter.");
            if(deviceData[i].time >= _dateFrom){
                if(i > 0){
                    if(!checkInputData(_sender, _speed, deviceData[i-1].latitude, deviceData[i-1].longitude, deviceData[i-1].time, deviceData[i].latitude, deviceData[i].longitude, deviceData[i].time)){
                        return (0,0,0,"");
                    }
                }
                if(actualIndex == _index){
                    return (deviceData[i].time, deviceData[i].latitude, deviceData[i].longitude, deviceData[i].note);
                }
                actualIndex ++;
            }
        }
        return (0,0,0,"");
    }

    /** 
    *@dev Retrieves device data based on the _deviceId and filters it by the _dateFrom and the _dateTo. If the _dateTo is 0, returns data up to now. Because solidity can not return array of structs, the function returns only one location data per call. Use the _index parameter to specific index of the wanted data.
    *@param _sender The sending address.
    *@param _deviceId The device id;
    *@param _index The index of the wanted data.
    *@param _dateFrom The firt acceptable date for the filter.
    *@param _dateTo The last acceptable date for the filter.
    *@return time, latitude, longitude, note. If is something wrong or no data, returns 0,0,0,"".
    */
    function getData(address _sender, uint _deviceId, uint _index, uint _dateFrom, uint _dateTo) public view returns(uint, int32, int32, string memory) {
        if(!_hasData(_deviceId)){
            return (0,0,0,"");
        }
        LocationData[] memory deviceData = _deviceData[_deviceId];
        uint actualIndex = 0;
        uint dateTo = _dateTo;
        if (_dateTo == 0){
            dateTo = now;
        }
        for(uint i = 0; i < deviceData.length; i++){
            require(deviceData[i].time <= dateTo, "The data not found. Try to change the date filter.");
            if(deviceData[i].time >= _dateFrom){
                if(actualIndex == _index){
                    return (deviceData[i].time, deviceData[i].latitude, deviceData[i].longitude, deviceData[i].note);
                }
                actualIndex ++;
            }
        }
        return (0,0,0,"");
    }

    /** 
    *@dev Saves a localization data based on the _deviceId. Only device owner can save, if it is set.
    *@param _sender The sending address.
    *@param _deviceId The device id;
    *@param _latitude The latitude.
    *@param _longitude The longitude.
    *@param _time The time.
    *@param _note The note.
    */
    function saveData(address _sender, uint _deviceId, int32 _latitude, int32 _longitude, uint _time, string memory _note) public onlyMainContract{
        require(_canSaveData(_sender, _deviceId), "The sender can not save the data.");
        require((_latitude >= -9000000) && (_latitude <= 9000000), "The _latitude does not have correct value.");
        require((_longitude >= -18000000) && (_longitude <= 18000000), "The _longitude does not have correct value.");
        require((_time >= (now - 172800)) && (_time < now + 600), "The location is too old or in future.");
        if(_hasData(_deviceId)){
            LocationData memory lastData = _deviceData[_deviceId][_deviceData[_deviceId].length-1];
            require((lastData.time <= _time) || (lastData.time == 0), "Saving data are older than the last saved data.");
        }
        _deviceData[_deviceId].push(LocationData(_latitude, _longitude, _time, _note));
    }

    /** 
    *@dev Saves a localization data based on the _deviceId. Only device owner can save, if it is  set.
    *@param _sender The sending address.
    *@param _speed The maximal device speed in kilometers per hour.
    *@param _deviceId The device id;
    *@param _latitude The latitude.
    *@param _longitude The longitude.
    *@param _time The time.
    *@param _note The note.
    */
    function saveData(address _sender, uint _speed, uint _deviceId, int32 _latitude, int32 _longitude, uint _time, string memory _note) public onlyMainContract{
        require(_canSaveData(_sender, _deviceId), "The sender can not save the data.");
        require(checkInputData(_sender, _speed, _deviceId, _latitude, _longitude, _time), "Passed position is invalid.");
        _deviceData[_deviceId].push(LocationData(_latitude, _longitude, _time, _note));
    }

    /** 
    *@dev Deletes a localization data based on the _deviceId and _localizationTime. Only device owner can delete.
    *@param _sender The sending address.
    *@param _deviceId The device id;
    *@param _localizationTime The localization time.
    */
    function deleteData(address _sender, uint _deviceId, uint _localizationTime) public onlyMainContract{
        require(_isDeviceOwner(_sender, _deviceId), "The sender is not the device owner.");
        require(_hasData(_deviceId), "The device does not have any data to delete.");
        for(uint i = 0; i < _deviceData[_deviceId].length; i++){
            if (_deviceData[_deviceId][i].time == _localizationTime){
                delete _deviceData[_deviceId][i];
                return;
            }
        }
        revert("Data not found.");
    }

    /** 
    *@dev Sets the sender as an owner of some device. The device can not have any previous data.
    *@param _sender The sending address.
    *@param _deviceId The device id;
    */
    function addDeviceOwner(address _sender, uint _deviceId) public onlyMainContract{
        require(!_hasData(_deviceId), "The device already has some data.");
        require(getDeviceOwner(_deviceId) == address(0), "The device already has some owner.");
        _deviceOwners[_deviceId] = DeviceOwnerSettings(_sender, Rights.DELETE);
    }


    /** 
    *@dev Retrieves data count based on date filters.
    *@param _sender The sending address.
    *@param _deviceId The device id;
    *@param _index The index of the wanted data.
    *@param _dateFrom The firt acceptable date for the filter.
    *@param _dateTo The last acceptable date for the filter.
    *@return data count
    */
    function getDataCount(address _sender, uint _deviceId, uint _dateFrom, uint _dateTo) public view returns(uint){
        if(!_hasData(_deviceId)){
            return 0;
        }
        LocationData[] memory deviceData = _deviceData[_deviceId];
        uint actualIndex = 0;
        uint dateTo = _dateTo;
        if (_dateTo == 0){
            dateTo = now;
        }
        for(uint i = 0; i < deviceData.length; i++){
            if(deviceData[i].time > dateTo){
                break;
            }
            if(deviceData[i].time >= _dateFrom){
                actualIndex ++;
            }
        }
        return actualIndex;
    }

    /** 
    *@dev Retrieves data count based on date and speed filter.
    *@param _sender The sending address.
    *@param _deviceId The device id;
    *@param _index The index of the wanted data.
    *@param _dateFrom The firt acceptable date for the filter.
    *@param _dateTo The last acceptable date for the filter.
    *@param _speed The limit speed.
    *@return data count
    */
    function getDataCount(address _sender, uint _deviceId, uint _dateFrom, uint _dateTo, uint _speed) public view returns(uint){
        if(!_hasData(_deviceId)){
            return 0;
        }
        if(_speed == 0){
            return 0;
        }
        LocationData[] memory deviceData = _deviceData[_deviceId];
        uint actualIndex = 0;
        uint dateTo = _dateTo;
        if (_dateTo == 0){
            dateTo = now;
        }
        for(uint i = 0; i < deviceData.length; i++){
            if(deviceData[i].time > dateTo){
                break;
            }
            if(deviceData[i].time >= _dateFrom){
                if(i > 0){
                    if(!checkInputData(_sender, _speed, deviceData[i-1].latitude, deviceData[i-1].longitude, deviceData[i-1].time, deviceData[i].latitude, deviceData[i].longitude, deviceData[i].time)){
                        return actualIndex;
                    }
                    actualIndex ++;
                }else{
                    actualIndex ++;
                }
            }
        }
        return actualIndex;
    }
}