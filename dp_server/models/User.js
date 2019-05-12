const mongoose = require('mongoose');
const uuid = require('uuid/v4');

const UserSchema = new mongoose.Schema({
    username: {
        type: String,
        required: true
    },
    password: {
        type: String,
        required: true
    },
    registerDate: {
        type: Date,
        default: Date.now
    },
    connectionKey: {
        type: String,
        default: uuid
    },
    devices: {
        type: [{
            deviceNumberHash: String,
            receivingKey: String,
            name: String
        }]
    },
});

const User = mongoose.model('User', UserSchema);

module.exports = User;