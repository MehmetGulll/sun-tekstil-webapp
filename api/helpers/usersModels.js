class User {
    constructor(id, ad, soyad, kullanici_adi, eposta, sifre, rol, status) {
        this.id = id;
        this.ad = ad;
        this.soyad = soyad;
        this.kullanici_adi = kullanici_adi;
        this.eposta = eposta;
        this.sifre = sifre;
        this.rol = rol;
        this.status = status;
    }
}
module.exports = User;