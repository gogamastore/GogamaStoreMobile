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

## 3. Arsitektur dan Desain Flutter

### Gaya & Desain

- **Tema**: Implementasikan sistem tema Material 3 penuh dengan mode Terang dan Gelap. Gunakan `ColorScheme.fromSeed` untuk palet warna yang konsisten.
- **Tipografi**: Gunakan paket `google_fonts` untuk tipografi yang bersih dan mudah dibaca yang cocok untuk aplikasi e-commerce.
- **Aset**: Migrasikan aset yang relevan (logo, ikon) dari proyek asli.

### Arsitektur yang Diterapkan

- **Manajemen Status**: Menggunakan `provider` (dengan `ChangeNotifier`) untuk mengelola status di seluruh aplikasi, seperti status otentikasi pengguna, item keranjang, dan tema.
- **Navigasi**: Menggunakan paket `go_router` untuk menangani perutean deklaratif. 
    - **Keputusan Desain Penting**: Untuk navigasi ke halaman detail (misalnya, dari katalog ke detail produk), **selalu gunakan `context.push()`**, bukan `context.go()`. Ini akan "mendorong" halaman baru ke atas tumpukan, yang secara otomatis memastikan **tombol kembali muncul di AppBar**. `context.go()` akan mereset tumpukan dan menghilangkan tombol kembali.
- **Struktur Proyek**: Atur file berdasarkan fitur (misalnya, `lib/src/features/authentication`, `lib/src/features/products`). Setiap fitur akan berisi layarnya sendiri, layanan, dan widget.
- **Layanan Backend**: Kelas layanan dibuat untuk berinteraksi dengan Firebase (misalnya, `AuthService`, `FirestoreService`).

## 4. Rencana Implementasi Saat Ini: Auto-Slide Banner

**Tujuan**: Membuat banner di halaman beranda menjadi auto-slide setiap 6 detik untuk meningkatkan dinamisme UI.

1.  **Identifikasi Widget**: Target modifikasi adalah widget banner di `lib/src/features/products/presentation/home_screen.dart`.
2.  **Konversi ke StatefulWidget**: Ubah widget banner menjadi `StatefulWidget` untuk mengelola `Timer` dan `PageController`.
3.  **Implementasikan Logika Auto-Slide**:
    - Inisialisasi `PageController` dan `Timer` di dalam `initState`.
    - Atur `Timer` untuk memicu pergantian halaman setiap 6 detik menggunakan `pageController.nextPage()`.
    - Tangani *looping* agar kembali ke halaman pertama setelah mencapai akhir.
    - Hentikan `Timer` di `dispose` untuk mencegah kebocoran memori.
