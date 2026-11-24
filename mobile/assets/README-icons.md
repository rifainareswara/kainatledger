# App Icon Setup

## Cara Ganti Launcher Icon

### Opsi 1: Pakai flutter_launcher_icons (Recommended)

1. **Siapkan icon PNG 1024x1024**
   - Simpan sebagai `assets/app-icon.png`
   - Untuk Android adaptive icon, buat juga `assets/app-icon-foreground.png`

2. **Generate icon**
   ```bash
   cd mobile
   flutter pub get
   dart run flutter_launcher_icons
   ```

3. **Rebuild APK**
   ```bash
   flutter build apk --release
   ```

### Opsi 2: Manual Replace

Replace file icon di folder berikut:

```
android/app/src/main/res/mipmap-hdpi/ic_launcher.png
android/app/src/main/res/mipmap-mdpi/ic_launcher.png
android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
```

Ukuran icon per folder:
- mipmap-mdpi: 48x48
- mipmap-hdpi: 72x72
- mipmap-xhdpi: 96x96
- mipmap-xxhdpi: 144x144
- mipmap-xxxhdpi: 192x192

### Generate Icon dengan Tools Online

Gunakan tools seperti:
- https://romannurik.github.io/AndroidAssetStudio/icons-launcher.html
- https://icon.kitchen/

Download icon pack, extract, copy ke folder mipmap sesuai ukuran.
