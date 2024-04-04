const { Sequelize } = require("sequelize");

let sequelize = null;

const initializeSequelize = async () => {
    sequelize = new Sequelize({
        database: process.env.DB_NAME,
        username: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        host: process.env.DB_HOST,
        dialect: "mssql",
        dialectOptions: {
            options: {
                encrypt: true,
            },
        },
    });

    try {
        await sequelize.authenticate();
        console.log("Connection has been established successfully.");
    } catch (error) {
        console.error("Unable to connect to the database:", error);
    }

    return sequelize;
};

module.exports = {
    sequelize,
    initializeSequelize,
};