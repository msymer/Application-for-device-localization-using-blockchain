const RecordList = require('../../models/RecordList');
const { getFromArray } = require('../../common');

class MDeviceData {
    constructor(request, response) {
        this.request = request;
        this.response = response;
    }

    async process() {
        const deviceName = this.request.query.deviceName;
        const devices = this.request.user.devices.map( d => d.name);
        if (!deviceName) {
            this.response.render('device-data', { 
                page: 'device-data', 
                data: [],
                devices: devices
            });
            return;
        }

        try {
            const records = await this.getDeviceRecords(deviceName);
            this.response.render('device-data', { 
                page: 'device-data', 
                data: records,
                deviceName: deviceName,
                devices: devices
            });
        } catch (err) {
            if(deviceName){
                this.response.render('device-data', { 
                    page: 'device-data', 
                    errors: [ {msg: err.message}],
                    devices: devices,
                    deviceName: deviceName
                });
            }else{
                this.response.render('device-data', { 
                    page: 'device-data', 
                    errors: [ {msg: err.message}],
                    devices: devices
                });
            }
        }
    }

    // Returns all tracking data of the device.
    async getDeviceRecords(deviceName) {
        const deviceNumberHash = getFromArray(this.request.user.devices, 'deviceNumberHash', (device) => {
            return (device.name == deviceName);
        });

        if (deviceNumberHash) {
            const recordList = await RecordList.findOne({ deviceNumberHash: deviceNumberHash });
            if (recordList && (recordList.records.length > 0)) {
                this.request.session.recordList = recordList;
                return recordList.records;
            } else {
                throw new Error('The device does not have any records.');
            }
        } else {
            throw new Error('User does not have the device in the connected devices.');
        }
    }
}

module.exports = MDeviceData;
