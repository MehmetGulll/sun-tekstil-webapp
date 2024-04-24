class Store{
    constructor(storeId,storeCode,storeName,storeType,regionId, city, storePhone, storeWidth, storeManager, status){
        this.storeId = storeId,
        this.storeCode = storeCode,
        this.storeName = storeName,
        this.storeType = storeType,
        this.regionId, regionId,
        this.city = city,
        this.storePhone = storePhone,
        this.storeWidth = storeWidth,
        this.storeManager = storeManager
        this.status = status;
    }
}
module.exports = Store;