const express = require('express');
const router = express.Router();
const passport = require('passport');
const {ensureAuthenticated} = require('../auth');
const UserRegister = require('./operations/user-register');

//Loads login page.
router.get('/login', (req, res) => res.render('login', {page: 'login'}));

//Loads register page.
router.get('/register', (req, res) => res.render('register', {page: 'register'}));

//Registers new user.
router.post('/register', (req, res) => {
    const operation = new UserRegister(req, res);
    operation.process();
});

//Log in user.
router.post('/login', (req, res, next)=>{
    passport.authenticate('local', {
        successRedirect: '/your-devices',
        failureRedirect: '/login',
        failureFlash: true
    })(req, res, next);
});

//Log out user.
router.get('/logout', ensureAuthenticated, (req, res) => {
    req.logout();
    req.flash('success_msg', 'You are logged out.');
    res.redirect('/login');
})
module.exports = router;