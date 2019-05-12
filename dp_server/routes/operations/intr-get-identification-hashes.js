const Device = require('../../models/Device');
const {getFromArray} = require('../../common');
const crypto = require('crypto');

class IntrGetIdentificationHashes {
    constructor(request, response) {
        this.request = request;
        this.response = response;
    }

    async process() {
        const deviceName = this.request.query.deviceName;

        if (!this.request.user.username) {
            this.response.status(400).send({ result: false, msg: "User must be logget in." });
            return;
        }

        try {
            if (!deviceName) {
                throw new Error('DevideName is missing.');
            }
            const deviceHashNumber = getFromArray(this.request.user.devices, 'deviceNumberHash', (device) => {
                return device.name == deviceName;
            });

            let identificators = [];
            const device = await Device.findOne({ deviceNumberHash: deviceHashNumber });
            if(device){
                for(let i = 0; i <= device.idHashVariable; i++){
                    let identificator = deviceHashNumber + i;
                    identificator = crypto.scryptSync(identificator, 'supersalt', 64).toString('hex');
                    identificators.push(identificator);
                }
                this.response.status(200).send({ result: true, identificationHashes: identificators });
                return;
            }
            this.response.status(400).send({ result: false, msg: "Device was not found." });
        } catch (err) {
            this.response.status(400).send({ result: false, msg: err.message });
        }
    }
}

module.exports = IntrGetIdentificationHashes;