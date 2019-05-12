var schedule = require('node-schedule');
const RecordList = require('./models/RecordList');
const { deleteFromArray } = require('./common');

module.exports = schedule.scheduleJob('0 0 * * *', async function () {
    let recordLists = await RecordList.find({ records: { $ne: [] } });
    const dateOld = Date.now() - (60 * 60 * 1000 * 48);
    for (const rList of recordLists) {
        deleteFromArray(rList.records, (record) => {
            return record.time < dateOld;
        });
        await rList.save();
    }
});;