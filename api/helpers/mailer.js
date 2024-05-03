const nodemailer = require("nodemailer");

async function sendMail(options) {
  try {
    // Transporter oluştur
    const transporter = nodemailer.createTransport({
      service: "gmail",
      host: "smtp.gmail.com",
      port: 465, // SMTP portu (genellikle 587 veya 465 olabilir)
      secure: true, // true ise SSL kullanılıyor demektir
      auth: {
        user: "sunteks64039@gmail.com", // SMTP sunucusu için kullanıcı adı
        pass: "xdzl vkqb ygaf pars", // SMTP sunucusu için şifre
      },
    });

    // Mail seçeneklerini ayarla
    const mailOptions = {
      from: options.from, // Gönderen adresi
      to: options.to, // Alıcı adresi
      subject: options.subject, // Mail konusu
      // text: options.text, // Mail içeriği (metin formatında)
      html: options.html, // Opsiyonel: HTML içeriği
      attachments: options.attachments, // Opsiyonel: Eklentiler
    };

    // Maili gönder
    const info = await transporter.sendMail(mailOptions);
    console.log("Mail başarıyla gönderildi:", info.response);
    return info;
  } catch (error) {
    console.error("Mail Gönderilemedi:", error);
    throw error;
  }
}

module.exports = { sendMail };
