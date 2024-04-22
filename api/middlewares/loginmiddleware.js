const loginMiddleware = (req,res,next)=>{
    const {user_name, userPassword} = req.body;
    if(!user_name || !userPassword) { 
        return res.status(400).send({message: 'Kullanıcı adı ve şifre gerekli.'});
    }
    if(user_name.length < 3 || userPassword.length <4){
        return res.status(400).send({message: 'Gerekli karakter sayısını giriniz'});

    }
    next();
}

module.exports = loginMiddleware;