const { DataTypes } = require('sequelize');
const sequelize = require('./sequelize'); 

const bolge = {
    bolge_id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false
    },
    bolge_adi: {
        type: DataTypes.STRING,
        allowNull: false
    },
    bolge_muduru: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: 'kullanici',
            key: 'id'
        }
    },
    bolge_kodu: {
        type: DataTypes.STRING,
        allowNull: false
    },
    status : {
        type: DataTypes.INTEGER,
        allowNull: false
    }
};

const denetim =  {
    denetim_id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false
    },
    denetim_tipi_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: 'denetim_tipi',
            key: 'denetim_tip_id'
        }
    },
    magaza_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: 'magaza',
            key: 'magaza_id'
        }
    },
    denetci_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: 'kullanici',
            key: 'id'
        }
    },
    alinan_puan: {
        type: DataTypes.INTEGER,
        allowNull: true
    },
    denetim_tarihi: {
        type: DataTypes.STRING,
        allowNull: false
    },
    denetim_tamamlanma_tarihi: {
        type: DataTypes.STRING,
        allowNull: true
    },
    status: {
        type: DataTypes.INTEGER,
        allowNull: false
    }
    
};

const denetim_sorulari = {
    ds_id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false
    },
    denetim_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: 'denetim',
            key: 'denetim_id'
        }
    },
    soru_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: 'soru',
            key: 'soru_id'
        }
    },
    cevap: {
        type: DataTypes.INTEGER,
        allowNull: false
    }
};

const denetim_tipi ={
    denetim_tip_id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false
    },
    denetim_tipi: {
        type: DataTypes.STRING,
        allowNull: false
    },
    denetim_tipi_kodu: {
        type: DataTypes.STRING,
        allowNull: false
    },
    status: {
        type: DataTypes.INTEGER,
        allowNull: false
    }
};

const kullanici ={
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false
    },
    ad: {
        type: DataTypes.STRING,
        allowNull: false
    },
    soyad: {
        type: DataTypes.STRING,
        allowNull: false
    },
    kullanici_adi: {
        type: DataTypes.STRING,
        allowNull: false
    },
    eposta: {
        type: DataTypes.STRING,
        allowNull: false
    },
    sifre: {
        type: DataTypes.STRING,
        allowNull: false
    },
    rol: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: 'rol',
            key: 'rol_id'
        }
    },
    status: {
        type: DataTypes.INTEGER,
        allowNull: false
    }
};

const magaza =  {
    magaza_id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false
    },
    magaza_kodu: {
        type: DataTypes.STRING,
        allowNull: false
    },
    magaza_adi: {
        type: DataTypes.STRING,
        allowNull: false
    },
    magaza_tipi: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: 'magaza_tipi',
            key: 'magaza_tip_id'
        }
    },
    bolge_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: 'bolge',
            key: 'bolge_id'
        }
    },
    sehir: {
        type: DataTypes.STRING,
        allowNull: false
    },
    magaza_telefon: {
        type: DataTypes.STRING,
        allowNull: false
    },
    magaza_metre: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    magaza_muduru: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: 'kullanici',
            key: 'id'
        }
    },
    acilis_tarihi: {
        type: DataTypes.STRING,
        allowNull: false
    },
    status: {
        type: DataTypes.INTEGER,
        allowNull: false, 
    },
    ekleyen_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: 'kullanici',
            key: 'id'
        }
    },

};

const magaza_tipi = {
    magaza_tip_id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false
    },
    magaza_tipi: {
        type: DataTypes.STRING,
        allowNull: false
    }
};

const rol ={
    rol_id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false
    },
    rol_adi: {
        type: DataTypes.STRING,
        allowNull: false
    },
    yetki_id: {
        type: DataTypes.STRING,
        allowNull: false
    }
};

const soru ={
    soru_id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false
    },
    soru_adi: {
        type: DataTypes.STRING,
        allowNull: false
    },
    soru_cevap: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    soru_puan: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    soru_sira_no: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    denetim_tip_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: 'denetim_tipi',
            key: 'denetim_tip_id'
        }
    },
    ekleyen_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: 'kullanici',
            key: 'id'
        }
    },
    guncelleyen_id: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: 'kullanici',
            key: 'id'
        }
    },
    status: {
        type: DataTypes.INTEGER,
        allowNull: false
    }
};

const yetki = {
    yetki_id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false
    },
    yetki_adi: {
        type: DataTypes.STRING,
        allowNull: false
    }
};

const aksiyon = {
    aksiyon_id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false
    },
    aksiyon_konu: {
        type: DataTypes.STRING,
        allowNull: false
    },
    aksiyon_gorsel: {
        type: DataTypes.STRING,
        allowNull: true
    },
    aksiyon_acilis_tarihi: {
        type: DataTypes.STRING,
        allowNull: false
    },
    aksiyon_bitis_tarihi: {
        type: DataTypes.STRING,
        allowNull: true
    },
    aksiyon_sure: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    aksiyon_oncelik: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    denetim_tip_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: 'denetim_tipi',
            key: 'denetim_tip_id'
        }
    },
    aksiyon_olusturan_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: 'kullanici',
            key: 'id'
        }
    },
    aksiyon_kapatan_id: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: 'kullanici',
            key: 'id'
        }
    },
    status: {
        type: DataTypes.INTEGER,
        allowNull: false
    }
};


module.exports = {
    bolge,
    denetim,
    denetim_sorulari,
    denetim_tipi,
    kullanici,
    magaza,
    magaza_tipi,
    rol,
    soru,
    yetki,
    aksiyon
};
