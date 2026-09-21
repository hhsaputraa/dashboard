# 🔐 Security Setup Guide

## AES Encryption Key Configuration

Aplikasi ini menggunakan AES-256-CBC encryption untuk mengenkripsi kredensial user sebelum dikirim ke backend. **Kunci enkripsi HARUS dikonfigurasi dengan benar** agar aplikasi dapat berfungsi.

---

## ⚠️ PENTING - Jangan Commit File `.env.json`

File `.env.json` berisi kunci enkripsi rahasia yang **TIDAK BOLEH** di-commit ke repository Git. File ini sudah ditambahkan ke `.gitignore`.

---

## 🚀 Setup untuk Development

### 1. Copy Template Environment File

```bash
cp .env.example .env.json
```

### 2. Generate AES Key (32 karakter)

**Menggunakan OpenSSL:**
```bash
openssl rand -hex 16
```

**Menggunakan Python:**
```python
import secrets
print(secrets.token_hex(16))
```

**Menggunakan Node.js:**
```javascript
require('crypto').randomBytes(16).toString('hex')
```

### 3. Edit File `.env.json`

```json
{
  "API_BASE_URL": "http://localhost:8097",
  "AES_KEY": "e7fb06ed97149099cc41f7ac055ea6e6"
}
```

**⚠️ Ganti `e7fb06ed97149099cc41f7ac055ea6e6` dengan key yang Anda generate!**

### 4. Pastikan Backend Menggunakan Key yang Sama

Kunci AES di aplikasi Flutter **HARUS SAMA** dengan kunci di backend Go. Update environment variable di backend:

```bash
# Backend Go
export AES_KEY="e7fb06ed97149099cc41f7ac055ea6e6"
```

---

## 📦 Build untuk Production

### Android APK/AAB

```bash
flutter build apk --dart-define-from-file=.env.json --release
```

atau

```bash
flutter build appbundle --dart-define-from-file=.env.json --release
```

### iOS

```bash
flutter build ios --dart-define-from-file=.env.json --release
```

---

## 🔒 Best Practices

### ✅ DO:
- Generate key unik untuk setiap environment (dev, staging, production)
- Simpan production key di secure vault (Azure Key Vault, AWS Secrets Manager)
- Gunakan key berbeda antara development dan production
- Rotate key secara berkala (setiap 3-6 bulan)
- Share key hanya melalui channel aman (encrypted messenger, vault)

### ❌ DON'T:
- ❌ Jangan commit `.env.json` ke Git
- ❌ Jangan hardcode key di source code
- ❌ Jangan share key di Slack/email/WhatsApp
- ❌ Jangan pakai key yang sama untuk semua environment
- ❌ Jangan pakai key contoh dari dokumentasi

---

## 🐛 Troubleshooting

### Error: "AES_KEY tidak ditemukan"

**Penyebab:** File `.env.json` tidak ada atau tidak di-load dengan benar.

**Solusi:**
1. Pastikan file `.env.json` ada di root project
2. Jalankan dengan flag: `--dart-define-from-file=.env.json`
3. Untuk debug di IDE, tambahkan di run configuration:
   - **VS Code:** Edit `launch.json`
   - **Android Studio:** Edit Run Configuration → Additional run args

### Error: "AES Key harus tepat 32 karakter"

**Penyebab:** Key yang di-generate tidak tepat 32 karakter.

**Solusi:**
- Gunakan command `openssl rand -hex 16` (menghasilkan 32 hex chars)
- Pastikan tidak ada spasi atau newline di awal/akhir key

### Backend Tidak Bisa Decrypt

**Penyebab:** Key di Flutter dan backend tidak sama.

**Solusi:**
1. Cek key di `.env.json` (Flutter)
2. Cek environment variable `AES_KEY` di backend
3. Pastikan kedua key identik (case-sensitive)

---

## 📝 Contoh Run Configuration

### VS Code (`launch.json`)

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter Dev",
      "request": "launch",
      "type": "dart",
      "args": [
        "--dart-define-from-file=.env.json"
      ]
    }
  ]
}
```

### Android Studio

1. Run → Edit Configurations
2. Pilih Flutter app configuration
3. Additional run args: `--dart-define-from-file=.env.json`

---

## 🔑 Key Rotation Checklist

Saat melakukan rotasi key (ganti key baru):

- [ ] Generate key baru dengan `openssl rand -hex 16`
- [ ] Update `.env.json` di semua developer machines
- [ ] Update environment variable di backend server
- [ ] Deploy backend dengan key baru
- [ ] Build & deploy aplikasi Flutter dengan key baru
- [ ] Test login dengan aplikasi versi baru
- [ ] Monitor error logs selama 24 jam
- [ ] Hapus key lama dari semua storage

---

## 📞 Kontak

Jika ada pertanyaan terkait security setup, hubungi tim DevOps atau Security team.
