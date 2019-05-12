const mongoose = require('mongoose');
const uuid = require('uuid/v4');

const DeviceSchema = new mongoose.Schema({
    deviceNumberHash: {
        type: String,
        required: true
    },
    receivingKey: {
        type: String,
        default: uuid
    },
    idHashVariable: {
        type: Number,
        default: 0
    },
    lastRecordTime: {
        type: Date,
        default: 0
    }
});

const Device = mongoose.model('Device', DeviceSchema);

module.exports = Device;