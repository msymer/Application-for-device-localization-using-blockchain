const User = require('../../models/User');
const uuid = require('uuid/v4');

class IntrGenerateConnectionKey{
    constructor(request, response) {
        this.request = request;
        this.response = response;
    }

    async process(){
        if (!this.request.user.username) {
            this.response.status(400).send({result: false, msg: "User must be logget in."});
            return;
        }

        try{
            const user = await User.findOne({username: this.request.user.username});
            if(!user){
                this.response.status(400).send({result: false, msg: 'User does not exist.'});
            }else{
                const newKey = uuid();
                user.connectionKey = newKey;
                await user.save();
                console.log(`User ${user.username} changed connection key.`);
                this.response.status(200).send({result: true});
            }
        }catch(err){
            this.response.status(400).send({result: false, msg: err.message});
        }
    }
}

module.exports = IntrGenerateConnectionKey;