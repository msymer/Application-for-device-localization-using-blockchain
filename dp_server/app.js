require('dotenv').load();
const express = require('express');
const expressLayouts = require('express-ejs-layouts');
const mongoose = require('mongoose');
const flash = require('connect-flash');
const session = require('express-session');
const passport = require('passport');
const https = require('https');
const fs = require('fs');

const app = express();

require('./passport')(passport);

mongoose.connect(process.env.MONGODB_URI, { useNewUrlParser: true})
.then(() => console.log("Database connected..."))
.catch(() => console.log(err));

require('./clean-db');

app.use(expressLayouts);
app.set('view engine', 'ejs');
app.use(express.static(__dirname + '/views'));
app.use(express.urlencoded({ extended: false}));

app.use(session({
    secret: 'dp secret',
    resave: true,
    saveUninitialized: true
}));

app.use(express.json());

app.use(passport.initialize());
app.use(passport.session());

app.use(flash());

app.use((req, res, next)=>{
    res.locals.success_msg = req.flash('success_msg');
    res.locals.error_msg = req.flash('error_msg');
    res.locals.error = req.flash('error');
    res.locals.loggedIn = false;
    next();
});

app.use('/', require('./routes/main'));
app.use('/', require('./routes/users'));
app.use('/api', require('./routes/api'));
app.use('/intr', require('./routes/internal'));

const PORT = process.env.PORT || 3000;

https.createServer({
    key: fs.readFileSync('./certificate/server.key'),
    cert: fs.readFileSync('./certificate/server.cert')
}, app).listen(PORT, console.log(` HTTPS Server started on port ${PORT}`));

