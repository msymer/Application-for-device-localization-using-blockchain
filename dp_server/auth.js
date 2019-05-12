module.exports = {
    ensureAuthenticated: function(req, res, next) {
        if(req.isAuthenticated()) {
            res.locals.loggedIn = true;
            return next();
        }
        req.flash('error_msg', 'Please log in.');
        res.redirect('/login');
    }
}