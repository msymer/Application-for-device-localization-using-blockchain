const User = require('../../models/User');
const crypto = require('crypto');
const {deleteFromArray} = require('../../common');

class ApiRemoveDevice {
    constructor(request, response) {
        this.request = request;
        this.response = response;
    }

    async process(){
        const {username, deviceNumber} = this.request.body;

        if (!username || !deviceNumber) {
            this.response.status(400).send({result: false, msg: "Wrong request. Something is missing."});
            return;
        }

        try{
            const deviceNumberHash = crypto.scryptSync(deviceNumber, 'supersalt', 64).toString('hex');

            const user = await User.findOne({username: username, 'devices.deviceNumberHash': deviceNumberHash});
            if(!user){
                this.response.status(400).send({result: false, msg: 'User with the device does not exist.'});
            }else{
                deleteFromArray(user.devices, (device) => {
                    return device.deviceNumberHash == deviceNumberHash;
                })
                await user.save();
                console.log(`Device ${deviceNumberHash} removed from user ${username}.`);
                this.response.status(200).send({result: true});
            }
        }catch(err){
            this.response.status(400).send({result: false, msg: err.message});
        }
    }
}

module.exports = ApiRemoveDevice;
