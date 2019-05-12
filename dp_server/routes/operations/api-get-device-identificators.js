const Device = require('../../models/Device');
const crypto = require('crypto');

class ApiGetDeviceIdentificators {
    constructor(request, response) {
        this.request = request;
        this.response = response;
        this.timeToChangeIdentificator = 172800000;
    }

    async process() {
        const deviceNumber = this.request.query.deviceNumber;
        const receivingKey = this.request.query.receivingKey;

        try {
            if (!deviceNumber || !receivingKey) {
                throw new Error('Device number or receiving key is missing.');
            }
            const deviceHashNumber = crypto.scryptSync(deviceNumber, 'supersalt', 64).toString('hex');

            const device = await Device.findOne({ deviceNumberHash: deviceHashNumber });
            if(!device){
                throw new Error('The device with the device number does not exist.');
            }

            if(device.receivingKey != receivingKey){
                throw new Error('Incorrect receiving key.');
            }

            let identificators = [];
            for(let i = 0; i <= device.idHashVariable; i++){
                let identificator = deviceHashNumber + i;
                identificator = crypto.scryptSync(identificator, 'supersalt', 64).toString('hex');
                identificators.push(identificator);
            }
            this.response.status(200).send({ result: true, identificationHashes: identificators });
        } catch (err) {
            this.response.status(400).send({ result: false, msg: err.message });
        }
    }
}

module.exports = ApiGetDeviceIdentificators;