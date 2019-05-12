const User = require('../../models/User');
const {changeInArray} = require('../../common');

class IntrRenameDevice{
    constructor(request, response) {
        this.request = request;
        this.response = response;
    }

    async process(){
        const {deviceName, deviceNumberHash} = this.request.body;

        if (!deviceName|| !deviceNumberHash) {
            this.response.status(400).send({result: false, msg: "Something is missing."});
            return;
        }

        try{
            const user = await User.findOne({username: this.request.user.username, 'devices.deviceNumberHash': deviceNumberHash});
            if(!user.username){
                this.response.status(400).send({result: false, msg: 'User with the device does not exist.'});
            }else{
                if (await this.nameExists(deviceName, this.request.user.username)){
                    throw new Error('Device name already exists.');
                }
                changeInArray(user.devices, 'name', deviceName, (device) => {
                    return device.deviceNumberHash == deviceNumberHash;
                });
                await user.save();
                console.log(`Device changed name to ${deviceName} in user ${this.request.user.username}.`);
                this.response.status(200).send({result: true});
            }
        }catch(err){
            this.response.status(400).send({result: false, msg: err.message});
        }
    }

    async nameExists(name, username){
        const user = await User.findOne({username: username, 'devices.name': name});
        if (user){
            return true;
        }
        return false;
    }
}

module.exports = IntrRenameDevice;