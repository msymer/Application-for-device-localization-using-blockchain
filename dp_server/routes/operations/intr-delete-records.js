const RecordList = require('../../models/RecordList');
const {deleteFromArray} = require('../../common');
const {getFromArray} = require('../../common');

class IntrDeleteRecords{
    constructor(request, response) {
        this.request = request;
        this.response = response;
    }

    async process(){
        const {selected, deviceName} = this.request.body;
        if (!selected || !deviceName) {
            this.response.status(400).send({result: false, msg: "Wrong request. Something is missing."});
            return;
        }

        try{
            await this.DeleteRecords(selected, deviceName);
            this.response.status(200).send({result: true});
        }catch(err){
            console.log(err);
            this.response.status(400).send({result: false, msg: err.message});
        }
    }

    //Deletes all selected records from device with the deviceName.
    async DeleteRecords(selected, deviceName){
        let selectedArray = JSON.parse(selected);
        const deviceNumberHash = getFromArray(this.request.user.devices, 'deviceNumberHash', (device)=> {
            return device.name == deviceName;
        });

        if(deviceNumberHash){
            const recordList = await RecordList.findOne({deviceNumberHash: deviceNumberHash});
            if(recordList){
                selectedArray.forEach((id) => {
                    deleteFromArray(recordList.records, (rec) => {
                        return rec._id == id;
                    });
                });
                await recordList.save();
                console.log(`Deleted ${selectedArray.length} records from device ${deviceNumberHash}.`);
            }else{
                throw new Error('The device does not have any list of records yet.');
            }
        }else{
            throw new Error('User does not have the device.');
        }
    }
}

module.exports = IntrDeleteRecords;