const express = require('express');
const router = express.Router();
const { ensureAuthenticated } = require('../auth');
const IntrRemoveDevice = require('./operations/intr-remove-device');
const IntrRenameDevice = require('./operations/intr-rename-device');
const IntrDeleteRecords = require('./operations/intr-delete-records');
const IntrGenerateConnectionKey = require('./operations/intr-generate-connection-key');
const IntrGetIdentificationHash = require('./operations/intr-get-identification-hash');
const IntrGetIdentificationHashes = require('./operations/intr-get-identification-hashes');

router.delete('/remove-device', ensureAuthenticated, (req, res) => {
    const operation = new IntrRemoveDevice(req, res);
    operation.process();
});

router.post('/rename-device', ensureAuthenticated, (req, res) => {
    const operation = new IntrRenameDevice(req, res);
    operation.process();
});

router.delete('/delete-records', ensureAuthenticated, (req, res) => {
    const operation = new IntrDeleteRecords(req, res);
    operation.process();
    // console.log('request.session.recordList');
    // console.log(JSON.parse(req.body.selected));
    // console.log(req.body);
});

router.get('/generate-connection-key', ensureAuthenticated, (req, res) => {
    const operation = new IntrGenerateConnectionKey(req, res);
    operation.process();
});

router.get('/get-identification-hash', ensureAuthenticated, (req, res) => {
    const operation = new IntrGetIdentificationHash(req, res);
    operation.process();
});

router.get('/get-identification-hashes', ensureAuthenticated, (req, res) => {
    const operation = new IntrGetIdentificationHashes(req, res);
    operation.process();
});

module.exports = router;