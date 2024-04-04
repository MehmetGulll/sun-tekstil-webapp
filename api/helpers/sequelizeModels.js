const {DataTypes} = require('sequelize');

const users = {
    user_id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
    },
    user_name: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    user_surname: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    user_email: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    user_password: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    user_role: {
        type: DataTypes.STRING,
        allowNull: false,
        referances: {
            model: 'roles',
            key: 'role_id',
        },
    },
}

const roles = {
    role_id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
    },
    role_name: {
        type: DataTypes.STRING,
        allowNull: false,
    },
}

module.exports = {
    users
};