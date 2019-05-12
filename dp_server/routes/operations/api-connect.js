const User = require('../../models/User');
const Device = require('../../models/Device');
const crypto = require('crypto');

class ApiConnect {
    constructor(request, response) {
        this.request = request;
        this.response = response;
    }

    async process(){
        const {deviceNumber, connectionKey, username} = this.request.body;

        if (!deviceNumber || !connectionKey || !username) {
            this.response.status(400).send({result: false, msg: "Wrong request. Something is missing."});
            return;
        }

        try{
            const deviceNumberHash = crypto.scryptSync(deviceNumber, 'supersalt', 64).toString('hex');
            await this.connectDevice(deviceNumberHash);
            await this.connectDeviceToUser(deviceNumberHash, username, connectionKey);
            console.log(`Device ${deviceNumberHash} connected to user ${username}.`);
            this.response.status(200).send({result: true});
        }catch(err){
            this.response.status(400).send({result: false, msg: err.message});
        }
    }

    //Adds device with the deviceNumberHash to MongoDB document devices.
    async connectDevice(deviceNumberHash){
        const device = await Device.findOne({deviceNumberHash: deviceNumberHash});
        if(!device){
            const newDevice = new Device({
                deviceNumberHash
            });
            await newDevice.save();
            console.log(`New device ${deviceNumberHash} was saved to device documents.`);
        }
    }

    //Adds the device to user.
    async connectDeviceToUser(deviceNumberHash, username, connectionKey){
        const user = await User.findOne({username: username, connectionKey: connectionKey});
        if(!user){
            throw new Error('Invalid username or connectionKey.');
        }else{
            if(!user.devices.some( d => d.deviceNumberHash === deviceNumberHash)){
                const device = await Device.findOne({deviceNumberHash: deviceNumberHash});
                const nameHash = crypto.createHash('md5').update(deviceNumberHash).digest('hex');
                const deviceName = `Device-${nameHash}`;
                if(!device){
                    throw new Error('Device was not saved and found.');
                }else{
                    user.devices.push({
                        deviceNumberHash: device.deviceNumberHash,
                        receivingKey: device.receivingKey,
                        name: deviceName
                    });
                    await user.save();
                }
            }
        }
    }
}

module.exports = ApiConnect;
