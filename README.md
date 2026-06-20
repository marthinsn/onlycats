# OnlyCats

OnlyCats adalah aplikasi Flutter untuk rescue dan adopsi kucing. Aplikasi ini membantu pengguna melaporkan kucing terlantar, melihat daftar kucing siap adopsi, mengajukan adopsi, menyimpan favorit, menerima notifikasi, dan berkomunikasi dengan admin. Admin dapat mengelola laporan rescue, data kucing, pengajuan adopsi, pengguna, notifikasi, dan chat.

## Fitur Aplikasi

### Pengguna

- Registrasi akun dengan nama, email, dan password.
- Login menggunakan email/password atau Google Sign-In.
- Reset password melalui Firebase Authentication.
- Melihat daftar kucing dari Firestore.
- Melihat detail kucing, status kesehatan, kepribadian, lokasi shelter, dan peta lokasi penjemputan.
- Membagikan detail kucing menggunakan fitur share.
- Menambahkan dan menghapus kucing favorit.
- Mengajukan formulir adopsi.
- Melihat riwayat pengajuan adopsi.
- Membuat laporan rescue dengan foto, kondisi kucing, deskripsi, catatan, nomor telepon, dan lokasi.
- Memilih lokasi rescue melalui OpenStreetMap dengan tracking GPS real-time.
- Melihat riwayat laporan rescue.
- Chat dengan admin.
- Menerima notifikasi lokal untuk update laporan, adopsi, dan aktivitas terkait.
- Mengubah profil, foto profil, dan password.

### Admin

- Login sebagai admin berdasarkan email khusus.
- Dashboard statistik kucing, rescue, dan adopsi.
- Melihat laporan rescue terbaru.
- Mengelola data kucing.
- Menambah, mengubah, menghapus, dan mempublikasikan data kucing.
- Mempublikasikan kucing dari laporan rescue.
- Melihat detail lokasi rescue melalui peta.
- Mengubah status laporan rescue.
- Mengelola pengajuan adopsi.
- Menyetujui atau menolak pengajuan adopsi.
- Mengubah status kucing menjadi `diadopsi` saat adopsi disetujui.
- Mengelola data pengguna.
- Membalas chat pengguna.
- Melihat dan menandai notifikasi.
- Mengubah profil dan password admin.
- Mencatat status online admin melalui koleksi `admin_status`.

## Teknologi

- Flutter dan Dart
- Firebase Core
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Google Sign-In
- Cloudinary untuk upload gambar
- Flutter Local Notifications
- Image Picker
- Flutter Map
- OpenStreetMap tile layer
- Nominatim reverse geocoding
- Geolocator
- LatLong2
- Share Plus
- Google Fonts
- Flutter SpinKit

## Struktur Project

```text
lib/
  data/        Data dummy dan controller profil
  models/      Model data kucing, laporan rescue, dan profil pengguna
  screens/     Halaman pengguna dan halaman admin
  services/    Service Firebase, Cloudinary, auth, notifikasi, favorit, rescue
  theme/       Konfigurasi warna aplikasi
  widgets/     Komponen UI reusable

assets/
  images/      Aset gambar aplikasi

android/       Konfigurasi Android
ios/           Konfigurasi iOS
web/           Konfigurasi Web
macos/         Konfigurasi macOS
linux/         Konfigurasi Linux
windows/       Konfigurasi Windows
test/          File testing Flutter
```

Catatan: di workspace ini juga ada folder `onlycats/` di dalam root project yang berisi salinan project. Gunakan root project ini sebagai folder utama saat menjalankan perintah Flutter.

## Alur Role Admin

Admin ditentukan dari email yang login. Konfigurasi berada di:

```text
lib/services/admin_service.dart
```

Email akan dianggap admin jika:

- memakai domain `@admin.com`, contoh `admin@admin.com`
- terdaftar di list `adminEmails`, saat ini berisi `admin@onlycats.id`

Registrasi dari aplikasi hanya untuk user biasa. Akun admin perlu dibuat melalui Firebase Console atau disiapkan manual sesuai kebutuhan.

## Koleksi Firestore

Aplikasi menggunakan beberapa koleksi utama:

- `users`
- `cats`
- `adoptions`
- `rescue_reports`
- `notifications`
- `chat_rooms`
- `admin_status`

Beberapa status penting yang digunakan:

- Laporan rescue: `Menunggu`, `Diproses`, `Selesai`
- Adopsi: `on hold`, `approved`, `rejected`
- Kucing: `tersedia`, `diadopsi`

## Prasyarat

Pastikan sudah menginstal:

- Flutter SDK
- Dart SDK
- Android Studio atau Visual Studio Code
- Emulator Android atau device fisik
- Firebase CLI jika ingin mengatur ulang konfigurasi Firebase
- FlutterFire CLI jika ingin generate ulang `firebase_options.dart`

Cek environment Flutter:

```bash
flutter doctor
```

## Instalasi

1. Buka folder project:

```bash
cd onlycats
```

2. Install dependency:

```bash
flutter pub get
```

3. Pastikan konfigurasi Firebase tersedia:

```text
lib/firebase_options.dart
android/app/google-services.json
firebase.json
```

Jika ingin menggunakan project Firebase berbeda, jalankan:

```bash
flutterfire configure
```

4. Aktifkan Authentication provider di Firebase:

- Email/Password
- Google

5. Aktifkan Cloud Firestore.

6. Pastikan konfigurasi Cloudinary sesuai di:

```text
lib/services/cloudinary_service.dart
```

Konfigurasi saat ini:

```dart
cloudName = 'dmopwxcar'
uploadPreset = 'onlycats_rescue_unsigned'
```

## Menjalankan Aplikasi

Jalankan aplikasi:

```bash
flutter run
```

Lihat daftar device:

```bash
flutter devices
```

Jalankan pada device tertentu:

```bash
flutter run -d <device_id>
```

Contoh menjalankan di Chrome:

```bash
flutter run -d chrome
```

## Permission yang Dibutuhkan

Fitur tertentu membutuhkan permission perangkat:

- Lokasi untuk memilih titik rescue dan menampilkan GPS real-time.
- Galeri/foto untuk upload foto kucing, foto rescue, dan foto profil.
- Notifikasi untuk menerima update lokal dari aplikasi.

## Testing dan Analisis

Jalankan test:

```bash
flutter test
```

Analisis kode:

```bash
flutter analyze
```

## Build

Build APK Android:

```bash
flutter build apk
```

Build Web:

```bash
flutter build web
```

## Catatan Pengembangan

- Entry point aplikasi berada di `lib/main.dart`.
- Halaman awal menggunakan `SplashScreen`.
- Route utama user: `/home`, `/rescue`, `/profile`.
- Route utama admin: `/admin/home`, `/admin/rescue`, `/admin/profile`, `/admin/chat`.
- Upload gambar rescue dan data kucing menggunakan Cloudinary.
- Peta menggunakan OpenStreetMap, sedangkan pencarian alamat dari koordinat menggunakan Nominatim.
- Notifikasi disimpan di Firestore dan ditampilkan secara lokal menggunakan `flutter_local_notifications`.
