const express = require('express');
const router = express.Router();
const { ensureAuthenticated } = require('../auth');
const uuid = require('uuid/v4');
const ApiConnect = require('./operations/api-connect');
const ApiRemoveDevice = require('./operations/api-remove-device');
const ApiSendData = require('./operations/api-send-data');
const ApiGetDeviceIdentificators = require('./operations/api-get-device-identificators');

//Loads API page.
router.get('/', ensureAuthenticated, (req, res) => {
    res.render('api', {page: 'api'});
});

//API for connecting device to user and server.
router.post('/connect', (req, res) => {
    const operation = new ApiConnect(req, res);
    operation.process();
});

//API for removing device from user.
router.delete('/remove-device', (req, res) => {
    const operation = new ApiRemoveDevice(req, res);
    operation.process();
});

router.post('/send-data', (req, res) => {
    const operation = new ApiSendData(req, res);
    operation.process();
});

router.get('/get-device-identificators', (req, res) => {
    const operation = new ApiGetDeviceIdentificators(req, res);
    operation.process();
});

module.exports = router;
