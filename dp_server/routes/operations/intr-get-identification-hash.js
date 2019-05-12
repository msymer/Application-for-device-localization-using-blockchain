const Device = require('../../models/Device');
const {getFromArray} = require('../../common');
const crypto = require('crypto');

class IntrGetIdentificationHash {
    constructor(request, response) {
        this.request = request;
        this.response = response;
        this.timeToChangeIdentificator = 172800000;
    }

    async process() {
        const deviceName = this.request.query.deviceName;
        const newRecordTime = this.request.query.newRecordTime;
        const rewrite = this.request.query.rewrite;

        if (!this.request.user.username) {
            this.response.status(400).send({ result: false, msg: "User must be logget in." });
            return;
        }

        try {
            if (!deviceName || !newRecordTime) {
                throw new Error('DevideName or record time is missing.');
            }

            const deviceHashNumber = getFromArray(this.request.user.devices, 'deviceNumberHash', (device) => {
                return device.name == deviceName;
            });

            const device = await Device.findOne({ deviceNumberHash: deviceHashNumber });
            if (((device.lastRecordTime.getTime() + this.timeToChangeIdentificator) >= new Date(newRecordTime).getTime()) || (device.lastRecordTime.getTime() == 0)) {
                let identificator = deviceHashNumber + device.idHashVariable;
                identificator = crypto.scryptSync(identificator, 'supersalt', 64).toString('hex');
                this.response.status(200).send({ result: true, identificationHash: identificator });
            } else {
                let identificator = deviceHashNumber + (device.idHashVariable + 1);
                if(rewrite){
                    device.idHashVariable = device.idHashVariable + 1;
                    await device.save();
                }
                identificator = crypto.scryptSync(identificator, 'supersalt', 64).toString('hex');
                this.response.status(200).send({ result: true, identificationHash: identificator });
            }
        } catch (err) {
            this.response.status(400).send({ result: false, msg: err.message });
        }
    }
}

module.exports = IntrGetIdentificationHash;