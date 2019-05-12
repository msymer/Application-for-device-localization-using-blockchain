const User = require('../../models/User');
const {deleteFromArray} = require('../../common');

class IntrRemoveDevice{
    constructor(request, response) {
        this.request = request;
        this.response = response;
    }

    async process(){
        const {deviceNumberHash} = this.request.body;

        if (!deviceNumberHash) {
            this.response.status(400).send({result: false, msg: "Wrong request. Something is missing."});
            return;
        }

        try{
            const user = await User.findOne({username: this.request.user.username, 'devices.deviceNumberHash': deviceNumberHash});
            if(!user){
                this.response.status(400).send({result: false, msg: 'User with the device does not exist.'});
            }else{
                deleteFromArray(user.devices, (device) => {
                    return (device.deviceNumberHash == deviceNumberHash);
                });
                await user.save();
                console.log(`Device ${deviceNumberHash} removed from user ${user.username}.`);
                this.response.status(200).send({result: true});
            }
        }catch(err){
            this.response.status(400).send({result: false, msg: err.message});
        }
    }
}

module.exports = IntrRemoveDevice;