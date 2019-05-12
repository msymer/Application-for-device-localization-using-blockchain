const mongoose = require('mongoose');

const RecordListSchema = new mongoose.Schema({
    deviceNumberHash: {
        type: String,
        required: true
    },
    records: {
        type: [{
            latitude: String,
            longitude: String,
            time: Date,
            note: String
        }]
    }
});

const RecordList = mongoose.model('RecordList', RecordListSchema);

module.exports = RecordList;