
# Blueprint: Migrasi Gogamastore ke Flutter

## 1. Ikhtisar

Dokumen ini menguraikan rencana untuk memigrasikan aplikasi e-commerce "Gogamastore" yang ada dari React Native (Expo) ke Flutter. Tujuan utamanya adalah mereplikasi semua fungsionalitas yang ada sambil memanfaatkan keunggulan Flutter untuk kinerja, basis kode tunggal, dan pengalaman pengguna yang kaya.

## 2. Analisis Aplikasi yang Ada

- **Framework**: React Native (Expo)
- **Navigasi**: Navigasi berbasis file (Stack dan Tab)
- **Backend**: Firebase (Authentication, Firestore) & Backend Python kustom.
- **Fitur Inti**:
    - Otentikasi Pengguna (Login/Registrasi)
    - Katalog Produk dengan Pencarian & Detail
    - Keranjang Belanja
    - Alur Checkout & Pembayaran
    - Riwayat Pesanan & Manajemen Profil
    - Notifikasi Push

## 3. Rencana Migrasi & Arsitektur Flutter

### Gaya & Desain

- **Tema**: Implementasikan sistem tema Material 3 penuh dengan mode Terang dan Gelap. Gunakan `ColorScheme.fromSeed` untuk palet warna yang konsisten.
- **Tipografi**: Gunakan paket `google_fonts` untuk tipografi yang bersih dan mudah dibaca yang cocok untuk aplikasi e-commerce.
- **Aset**: Migrasikan aset yang relevan (logo, ikon) dari proyek asli.

### Arsitektur yang Direncanakan

- **Manajemen Status**: Gunakan `provider` (dengan `ChangeNotifier`) untuk mengelola status di seluruh aplikasi, seperti status otentikasi pengguna, item keranjang, dan tema.
- **Navigasi**: Gunakan paket `go_router` untuk menangani perutean deklaratif, tautan dalam, dan pengalihan berbasis otentikasi. Ini sangat ideal untuk aplikasi e-commerce yang kompleks.
- **Struktur Proyek**: Atur file berdasarkan fitur (misalnya, `lib/src/features/authentication`, `lib/src/features/products`). Setiap fitur akan berisi layarnya sendiri, layanan, dan widget.
- **Layanan Backend**: Buat kelas layanan untuk berinteraksi dengan Firebase (misalnya, `AuthService`, `FirestoreService`) dan backend Python.

## 4. Rencana Implementasi Saat Ini

**Fase 1: Fondasi & Otentikasi**

1.  **Inisialisasi Proyek**: Proyek Flutter dasar telah dibuat.
2.  **Tambahkan Ketergantungan**: Tambahkan `google_fonts`, `provider`, `go_router`, `firebase_core`, dan `firebase_auth`.
3.  **Konfigurasi Firebase**: Siapkan Firebase di proyek Flutter agar dapat terhubung ke backend Firebase yang ada.
4.  **Siapkan Perutean (`go_router`)**: Tentukan rute awal untuk layar splash, login, registrasi, dan halaman beranda (setelah login). Implementasikan pengalihan untuk melindungi rute yang diautentikasi.
5.  **Buat UI Otentikasi**: Bangun widget untuk layar Login dan Registrasi berdasarkan UI React Native yang ada.
6.  **Implementasikan Logika Otentikasi**: Buat `AuthService` yang menangani logika untuk `signInWithEmailAndPassword`, `createUserWithEmailAndPassword`, dan `signOut`. Gunakan `AuthProvider` untuk mengekspos status otentikasi ke pohon widget.

