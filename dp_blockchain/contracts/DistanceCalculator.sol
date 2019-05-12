pragma solidity ^0.5.6;

contract DistanceCalculator{
    int constant private A0 = 15707288;
    int constant private A1 = -2121144;
    int constant private A2 = 742610;
    int constant private A3 = -187293;
    int constant private PI = 31415926;
    int constant private R = 6371;
    int constant private D180 = 31415926;
    int constant private D360 = 62831853;

    /** 
    *@dev Returns _value raised to power of _ex (_value^_ex). 1 = 10000000.
    *@param _value The input value.
    *@param _ex Must be >= 0;
    *@return _value raised to power of _ex (_value^_ex)
    */
    function _pow(int _value, int _ex) private pure returns(int){ 
        require(_ex >=0, "Incorrect input value.");
        int result = 10000000; 
        for(int i = 0; i < _ex; i++){ 
            result = result * _value/10000000; 
        } 
        return result; 
    } 

    /** 
    *@dev Calculates factorial.
    *@param _value The input value.
    *@return factorial
    */
    function _fact(int _value) private pure returns(int) 
    { 
        require(_value >= 0, "Incorrect input value.");
        if (_value == 1 || _value == 0) return 1; 
        int result = 1; 
        for (int i = 1; _value >= i; i++){ 
            result = result * i; 
        } 
        return result; 
    } 

    /** 
    *@dev Calculates the square root of the number.
    *@param _x The input value.
    *@return The square root of the number without decimals.
    */
    function _sqrt(int _x) private pure returns (int) {
        require(_x >=0, "Incorrect input value.");
        int z = (_x + 1) / 2;
        int y = _x;
        while (z < y) {
            y = z;
            z = (_x / z + z) / 2;
        }
        return y;
    }

    /** 
    *@dev Counts absolute value.
    *@param _value The input value.
    *@return Absolute value.
    */
    function _absolute(int _value) private pure returns(uint) {
        if (_value < 0){
            return uint(_value * -1);
        }else{
            return uint(_value);
        }
    }

    /** 
    *@dev Calculates sine. Input is in radians and 1.0 = 10000000, 0.0000001 = 1
    *@param _value The input value.
    *@return Sine in radians. 1.0 = 10000000, 0.0000001 = 1
    */
    function _sin(int _value) private pure returns(int){
        int result = 0;
        for (int i = 0; i < 5; i++)
        {
            int val1 = _pow(-10000000, i);
            int val2 = _pow(_value, 2 * i + 1);
            int val3 = _fact(2 * i + 1);
            int val = val1 * (val2 / val3) / 10000000;
            result = result + val;
        }
        if(result > 10000000){
            return 10000000;
        }else if (result < -10000000){
            return -10000000;
        }
        return result;
    }

    /** 
    *@dev Calculates cosine. Input is in radians and 1.0 = 10000000, 0.0000001 = 1
    *@param _value The input value.
    *@return Cosine in radians. 1.0 = 10000000, 0.0000001 = 1
    */
    function _cos(int _value) private pure returns(int){
        int result = 0;
        for (int i = 0; i < 5; i++)
        {
            int val1 = _pow(-10000000, i);
            int val2 = _pow(_value, 2 * i);
            int val3 = _fact(2 * i);
            int val = val1 * (val2 / val3) / 10000000;
            result = result + val;
        }
        if(result > 10000000){
            return 10000000;
        }else if (result < -10000000){
            return -10000000;
        }
        return result;
    }

    /** 
    *@dev Calculates arcsine. Input value has 7 decimals, example: 1.0 = 10000000, 0.0000001 = 1
    *@param _value The input value.
    *@return Arcsine in radians. 1.0 = 10000000, 0.0000001 = 1
    */
    function _arcsin(int _value) private pure returns(int){ 
        require((_absolute(_value) <= 10000000), "Incorrect input value.");
        int result = _value;
        if(_value < 5500000){
        for (int i = 1; i < 5; i++)
        {
            int val1 = _fact(2 * i) * 100000000000000;
            int val2 = _pow(20000000, 2*i) * _pow(_fact(i)*10000000, 2) / 10000000;
            int val3 = _pow(_value, 2 * i + 1);
            int val4 = 2 * i + 1;
            int val = ((val1 / val2)) * (val3 / val4)/10000000;
            result = result + val;
        }
        }else{
            int val1 = PI/2;
            int val2 = _sqrt((10000000-_value)*10000000);
            int val3 = A0 + (A1 * _value/10000000) + (A2 * _pow(_value,2)/10000000) + (A3 * _pow(_value,3)/10000000);
            int val = val1 - (val2 * val3 / 10000000);
            result = val;
        }
        if(result > 15707963){
            return 15707963;
        }else if(result < -15707963){
            return -15707963;
        }
        return result; 
    }

    /** 
    *@dev Calculates arccosine. Input value has 7 decimals, example: 1.0 = 10000000, 0.0000001 = 1
    *@param _value The input value.
    *@return Arccosine in radians. 1.0 = 10000000, 0.0000001 = 1
    */
    function _arccos(int _value) private pure returns(int){
        require((_absolute(_value) <= 10000000), "Incorrect input value");
        int val1 = PI/2;
        int result = val1 - _arcsin(_value);
        if(result > PI){
            return PI;
        }else if(result < 0){
            return 0;
        }
        return result;
    }
    
    /** 
    *@dev Returns distance in kilometers between a two points. Last 5 numbers in the coordinates are behind the floating point.
    *@param _latitude1 The latitude of the first point.
    *@param _longitude1 The longitude of the first point.
    *@param _latitude2 The latitude of the second point.
    *@param _longitude2 The longitude of the second point.
    *@return Distance between a two points in kilometers.
    */
    function _calculateDistance(int _latitude1, int _longitude1, int _latitude2, int _longitude2) private pure returns(int){
        int lat1 = _latitude1 * 174532 / 100000;
        int lgt1 = _longitude1 * 174532 / 100000;
        int lat2 = _latitude2 * 174532 / 100000;
        int lgt2 = _longitude2 * 174532 / 100000;
        int lgt = int(_absolute(lgt2 - lgt1));
        if (lgt > D180){
            lgt = D360 -lgt;
        }
        int val1 = _sin(lat1) * _sin(lat2) / 10000000;
        int val2 = _cos(lat1) * _cos(lat2) * _cos(lgt)/100000000000000;
        int val = val1 + val2;
        if(val > 10000000){
            val = 10000000;
        }else if (val < -10000000){
            val = -10000000;
        }
        return _arccos(val) * R/10000000;
    }

    /** 
    *@dev Returns distance in meters between a two points. Last 5 numbers in the coordinates are behind the floating point. This is the second way, how to calcualte distance using Pythagorean theorem.
    *@param _latitude1 The latitude of the first point.
    *@param _longitude1 The longitude of the first point.
    *@param _latitude2 The latitude of the second point.
    *@param _longitude2 The longitude of the second point.
    *@return Distance between a two points in meters.
    */
    function _calculateDistance2(int32 _latitude1, int32 _longitude1,int32 _latitude2, int32 _longitude2) private pure returns (int){
        require((_latitude1 >= -9000000) && (_latitude1 <= 9000000), "The _latitude1 does not have correct value.");
        require((_latitude2 >= -9000000) && (_latitude2 <= 9000000), "The _latitude2 does not have correct value.");
        require((_longitude1 >= -18000000) && (_longitude1 <= 18000000), "The _longitude1 does not have correct value.");
        require((_longitude2 >= -18000000) && (_longitude2 <= 18000000), "The _longitude2 does not have correct value.");

        int a = int(_absolute(_latitude1 - _latitude2) * 111200);
        int lgt_d = int(_absolute(_longitude1-_longitude2));
        if(lgt_d > 18000000){
            lgt_d = 36000000 - lgt_d;
        }
        int b = int(lgt_d) * (_cos(((int(_latitude1) + int(_latitude2))/2)* 174532 / 100000))/100 * 111200/100000;
        int c;
        if (b == 0){
            c = a;
        }else if (a == 0){
            c = b;
        }else{
            a = _pow(a,2);
            b = _pow(b,2);
            c = _sqrt((a + b)/10)*10000;
        }
        return c/100000;
    }

    /** 
    *@dev Returns hour speed in kilometers km/h. Last 5 numbers in the coordinates are behind the floating point.
    *@param _latitude1 The latitude of the first point.
    *@param _longitude1 The longitude of the first point.
    *@param _time1 The time of the first point.
    *@param _latitude2 The latitude of the second point.
    *@param _longitude2 The longitude of the second point.
    *@param _time2 The time of the second point.
    *@return Hour speed in kilometers.
    */
    function _calculateSpeed(int32 _latitude1, int32 _longitude1, uint _time1, int32 _latitude2, int32 _longitude2, uint _time2) internal pure returns (uint) {
        require(_time1 <= _time2, "The _time1 must have equal or smaller value than the _time2.");
        uint time = _absolute(int(_time2 - _time1));
        if(time == 0){ 
            return 0;
        }
        uint distance = uint(_calculateDistance(_latitude1, _longitude1, _latitude2, _longitude2));
        return 1 hours * distance / time;
    }

    /** 
    *@dev Returns hour speed in meters. Last 5 numbers in the coordinates are behind the floating point. Count with _calculateDistance2().
    *@param _latitude1 The latitude of the first point.
    *@param _longitude1 The longitude of the first point.
    *@param _time1 The time of the first point.
    *@param _latitude2 The latitude of the second point.
    *@param _longitude2 The longitude of the second point.
    *@param _time2 The time of the second point.
    *@return Hour speed in meters.
    */
    function _calculateSpeed2(int32 _latitude1, int32 _longitude1, uint _time1, int32 _latitude2, int32 _longitude2, uint _time2) internal pure returns (uint) {
        require(_time1 <= _time2, "The _time1 must have equal or smaller value than the _time2.");
        uint time = _absolute(int(_time2 - _time1));
        if(time == 0){ 
            return 0;
        }
        uint distance = uint(_calculateDistance2(_latitude1, _longitude1, _latitude2, _longitude2));
        return 1 hours * distance / time;
    }


    


}