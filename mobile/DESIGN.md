# Design Direction: KainatLedger

## Identity & Tone
KainatLedger adalah aplikasi pencatat keuangan pribadi yang mengutamakan kejelasan, ketepatan angka, rasa aman, dan kemudahan navigasi.
Bukan sekadar aplikasi pencatatan biasa, antarmuka dirancang agar pengguna dapat melihat posisi finansial mereka dalam sekejap tanpa distraksi visual berlebihan.

## Three Dials (antislop)
- **ENERGY: 1 (Calm)**: Antarmuka yang tenang, terstruktur, fokus pada angka dan keterbacaan data keuangan.
- **RHYTHM: 2 (Balanced)**: Komposisi kartu metrik yang konsisten, list transaksi bertanggal yang rapi, dan grafik visual yang proporsional.
- **MOTION: 1 (Subtle)**: Transisi halaman yang halus, animasi state perubahan data yang natural tanpa efek pantul/floating yang berlebihan.

## Color Palette
- **Primary**: Slate Blue `#2563EB` (Aksen utama, tombol aksi, seleksi aktif)
- **Primary Dark**: `#1D4ED8` (State ditekan / hover)
- **Primary Light**: `#EFF6FF` (Highlight container, badge latar)
- **Financial Accents**:
  - Income: Emerald Green `#16A34A`
  - Expense: Crimson Red `#DC2626`
- **Neutrals**:
  - Surface Background: `#F8FAFC`
  - Card / Sheet Surface: `#FFFFFF`
  - Border / Divider: `#E2E8F0`
  - Text Primary: `#0F172A`
  - Text Secondary: `#64748B`
  - Text Muted: `#94A3B8`

## Typography & Numbers
- Font default: Clean system sans-serif (Inter / Roboto)
- Nilai mata uang (Rupiah): Format standar Indonesia (`Rp 1.500.000`), selalu jelas membedakan pemasukan (+) dan pengeluaran (-).

## UI State Mandate
Setiap layar data wajib mengimplementasikan 3 state:
1. **Loading State**: Shimmer atau circular progress terpusat yang halus.
2. **Empty State**: Ilustrasi/ikon yang relevan dengan pesan edukatif dan tombol aksi pertama (contoh: "Belum ada transaksi bulan ini. Catat transaksi pertama Anda").
3. **Error State**: Pesan kegagalan yang manusiawi dan tombol coba lagi (Retry).
