const RecordList = require('../../models/RecordList');
const { getFromArray } = require('../../common');

class MMap {
    constructor(request, response) {
        this.request = request;
        this.response = response;
    }

    async process() {
        const deviceName = this.request.query.deviceName;
        const devices = this.request.user.devices.map( d => d.name);
        if (!deviceName) {
            this.response.render('map', { 
                page: 'map', 
                devices: devices
            });
        }else{
            this.response.render('map', { 
                page: 'map', 
                deviceName: deviceName,
                devices: devices
            });
        }
    }
}

module.exports = MMap;
