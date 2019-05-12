const bcrypt = require('bcryptjs');
const User = require('../../models/User');

class UserRegister {
    constructor(request, response) {
        this.request = request;
        this.response = response;
    }

    async process(){
        const { username, password, password2 } = this.request.body;
        let errors = [];

        try{
            await this.checkRequestData(username, password, password2);
            await this.registerUser(username, password);
            console.log(`User ${username} registered.`);
            this.request.flash('success_msg', 'You are registered successfully. Please log in.');
            this.response.redirect('/login');
        }catch(err){
            if(err.message){
                errors.push({msg: err.message});
            }else{
                errors.push({msg: 'Error during registration. Please try it again.'});
            }
            console.log(err.message);
            this.response.render('register', {
                errors, username, password, password2, page: 'register'
            });
        }
    }

    //Checks request data. If data are incorrect, throws error.
    async checkRequestData(username, password, password2){
        if (!username || !password || !password2) {
            throw new Error('Some required fields are empty.');
        }
    
        if (password.length < 5) {
            throw new Error('Password must have at least 5 characters.');
        }
    
        if (password != password2) {
            throw new Error('Passwords do not match.');
        }

        const user = await User.findOne({ username: username });
        if (user) {
            throw new Error('User already exists.');
        }
    }

    /**
     * @returns {Promise<any>}
     * 
     */
    hashPassword(password){
        return new Promise((resolve, reject) => {
            bcrypt.genSalt(10, (err, salt) =>{
                bcrypt.hash(password, salt, (err, hash) =>{
                    if (err) {
                        reject(err);
                        return;
                    };
                    resolve(hash);
                });
            });
        });
    }

    //Register user with the username and password.
    async registerUser(username, password){
        const passwordHash = await this.hashPassword(password);
        const newUser = new User({
            username,
            password: passwordHash
        });
        await newUser.save();
    }
}

module.exports = UserRegister;
