class User{
    constructor(userId, userName,  userSurname,user_name, userEposta, userPassword, userRoleId, userRole ) {
        this.userId = userId;
        this.userName = userName;
        this.userSurname= userSurname;
        this.user_name= user_name;
        this.userEposta= userEposta;
        this.userRoleId = userRoleId,
        this.userRole = userRole;
      }
}
module.exports = User;