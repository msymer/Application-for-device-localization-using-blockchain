const Device = require('../../models/Device');
const RecordList = require('../../models/RecordList');
const crypto = require('crypto');

class ApiSendData {
    constructor(request, response) {
        this.request = request;
        this.response = response;
    }

    async process(){
        const {deviceNumber, coordinates} = this.request.body;

        if (!deviceNumber || !coordinates || !coordinates.latitude || !coordinates.longitude || !coordinates.time) {
            this.response.status(400).send({result: false, msg: "Wrong request. Something is missing."});
            return;
        }

        try{
            const deviceNumberHash = crypto.scryptSync(deviceNumber, 'supersalt', 64).toString('hex');
            await this.CheckRequestData(deviceNumberHash, coordinates);
            await this.SaveData(deviceNumberHash, coordinates);
            this.response.status(200).send({result: true});
        }catch(err){
            this.response.status(400).send({result: false, msg: err.message});
        }
    }

    // Saves data do RecordList based on deviceNumberHash
    async SaveData(deviceNumberHash, coordinates){
        let recordList = await RecordList.findOne({deviceNumberHash: deviceNumberHash});
        if(!recordList){
            recordList = new RecordList({
                deviceNumberHash, 
                records: []
            });
        }

        recordList.records.push({
            latitude: coordinates.latitude,
            longitude: coordinates.longitude,
            time: coordinates.time,
            note: coordinates.note
        });
        
        await recordList.save();
    }

    // Checks if device with the deviceNumberHash is connected and if latitude and longitude have correct value.
    async CheckRequestData(deviceNumberHash, coordinates){
        const device = await Device.findOne({deviceNumberHash: deviceNumberHash});
        if(!device){
            throw new Error('Device with the device number was not connected yet.');
        }

        const lat = parseFloat(coordinates.latitude);
        const lgt = parseFloat(coordinates.longitude);
        const time = Number(coordinates.time);

        if(!lat || !lgt){
            throw new Error('Latitude and longitude must be a number.');
        }

        if((lat < -90) || (lat > 90)){
            throw new Error('Latitude has incorrect value.');
        }

        if((lgt < -180) || (lgt > 180)){
            throw new Error('Longitude has incorrect value.');
        }

        const limitTime = Date.now() + (60 * 60 * 1000 * 6);
        if((time > limitTime)){
            throw new Error('Time is not correct.');
        }
    }
}

module.exports = ApiSendData;
