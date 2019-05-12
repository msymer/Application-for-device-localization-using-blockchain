const express = require('express');
const router = express.Router();
const { ensureAuthenticated } = require('../auth');
const { Coordinates, getPathes } = require('../map');
const MDeviceData = require('./operations/m-device-data');
const MMap = require('./operations/m-map');


router.get('/', ensureAuthenticated, (req, res) => res.redirect('/your-devices'));

router.get('/your-devices', ensureAuthenticated, (req, res) => res.render('your-devices', {
    username: req.user.username, 
    page: 'your-devices',
    devices: req.user.devices,
    connectionKey: req.user.connectionKey
}));

router.get('/device-data', ensureAuthenticated, (req, res) => {
    const operation = new MDeviceData(req, res);
    operation.process();
});

const coords = [];
coords.push(new Coordinates(49.195060, 16.606837, Date.now(), 'some very interesting note'));
coords.push(new Coordinates(49.196, 16.608, Date.now(), 'some very interesting note'));
coords.push(new Coordinates(49.197, 16.6068, Date.now(), undefined));
coords.push(new Coordinates(49.195, 16.606, Date.now(), 'some very interesting note'));
coords.push(new Coordinates(49.190, 16.60, Date.now(), 'some very interesting note'));

coords.push(new Coordinates(49.195060, 16.606837, Date.now(), 'some very interesting note'));
coords.push(new Coordinates(49.196, 16.608, Date.now(), 'some very interesting note'));
coords.push(new Coordinates(49.197, 16.6068, Date.now(), undefined));
coords.push(new Coordinates(49.195, 16.606, Date.now(), 'some very interesting note'));
coords.push(new Coordinates(49.190, 16.60, Date.now(), 'some very interesting note'));
//#region test
// coords.push(new Coordinates(0.001, 0.001));
// coords.push(new Coordinates(0.002, 0.002));
// coords.push(new Coordinates(0.004, 0.004));
// coords.push(new Coordinates(0.008, 0.008));
// coords.push(new Coordinates(0.016, 0.016));
// coords.push(new Coordinates(0.032, 0.032));
// coords.push(new Coordinates(-0.001, -0.001));
// coords.push(new Coordinates(-0.002, -0.002));
// coords.push(new Coordinates(-0.004, -0.004));
// coords.push(new Coordinates(-0.008, -0.008));
// coords.push(new Coordinates(-0.016, -0.016));
// coords.push(new Coordinates(-0.032, -0.032));

// coords.push(new Coordinates(0.000, 0.001));
// coords.push(new Coordinates(0.000, 0.002));
// coords.push(new Coordinates(0.000, 0.004));
// coords.push(new Coordinates(0.000, 0.008));
// coords.push(new Coordinates(0.000, 0.016));
// coords.push(new Coordinates(0.000, 0.032));
// coords.push(new Coordinates(-0.000, -0.001));
// coords.push(new Coordinates(-0.000, -0.002));
// coords.push(new Coordinates(-0.000, -0.004));
// coords.push(new Coordinates(-0.000, -0.008));
// coords.push(new Coordinates(-0.000, -0.016));
// coords.push(new Coordinates(-0.000, -0.032));

// coords.push(new Coordinates(0.001, 0.000));
// coords.push(new Coordinates(0.002, 0.000));
// coords.push(new Coordinates(0.004, 0.000));
// coords.push(new Coordinates(0.008, 0.000));
// coords.push(new Coordinates(0.016, 0.00));
// coords.push(new Coordinates(0.032, 0.00));
// coords.push(new Coordinates(-0.001, -0.000));
// coords.push(new Coordinates(-0.002, -0.000));
// coords.push(new Coordinates(-0.004, -0.000));
// coords.push(new Coordinates(-0.008, -0.000));
// coords.push(new Coordinates(-0.016, -0.00));
// coords.push(new Coordinates(-0.032, -0.00));

// coords.push(new Coordinates(0.000, 0.0005));
// coords.push(new Coordinates(0.000, -0.0005));

//#endregion test


router.get('/map', ensureAuthenticated, (req, res) => {
    const operation = new MMap(req, res);
    operation.process();
});

//Loads map page.
// router.get('/map', ensureAuthenticated, (req, res) => res.render('map', {
//     page: 'map',
//     coordinates: coords,
//     pathes: getPathes([coords])
// }));

// //TODO - dodelat pro cas a prave data
// router.post('/map', ensureAuthenticated, (req, res) => {
//     const { device, showMarkers, showPathes } = req.body;
//     res.render('map', {
//         page: 'map',
//         coordinates: (showMarkers ? coords : undefined),
//         pathes: (showPathes ? getPathes([coords]) : undefined) 
//     });
// });

module.exports = router;