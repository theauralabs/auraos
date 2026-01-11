#!/bin/bash
set -e

echo "========================================="
echo " AuraOS Logo Entegrasyonu"
echo "========================================="

LOGO_SOURCE="branding/logo.png"
LOGO_DIR="branding"

# Logo kontrolü
if [ ! -f "$LOGO_SOURCE" ]; then
    echo "⚠️  Logo dosyası bulunamadı: $LOGO_SOURCE"
    echo "Lütfen 1544x1325 boyutundaki logo.png dosyanızı branding/ dizinine koyun."
    exit 1
fi

# ImageMagick ile logo boyutlandırma
echo "🎨 Logo varyasyonları oluşturuluyor..."

# Farklı boyutlarda ikonlar
for size in 16 32 48 64 128 256 512; do
    convert "$LOGO_SOURCE" -resize ${size}x${size} \
        -background transparent -gravity center -extent ${size}x${size} \
        "$LOGO_DIR/icons/auraos-logo-${size}.png"
    echo "  ✓ ${size}x${size} ikon oluşturuldu"
done

# Plymouth boot logo (512x512)
convert "$LOGO_SOURCE" -resize 512x512 \
    -background transparent -gravity center \
    "$LOGO_DIR/plymouth/auraos-logo.png"
echo "  ✓ Plymouth logo oluşturuldu"

# GRUB boot logo (800x600 backdrop)
convert "$LOGO_SOURCE" -resize 400x400 \
    -background "#1a1a2e" -gravity center -extent 800x600 \
    "$LOGO_DIR/grub/auraos-grub.png"
echo "  ✓ GRUB logo oluşturuldu"

# Wallpaper (1920x1080) - Logo merkeze yerleştirilmiş
convert -size 1920x1080 xc:"#1a1a2e" \
    "$LOGO_SOURCE" -resize 600x600 -gravity center -composite \
    "$LOGO_DIR/wallpapers/auraos-wallpaper.png"
echo "  ✓ Wallpaper oluşturuldu"

# KDE, GNOME, XFCE için distributor logos
cp "$LOGO_DIR/icons/auraos-logo-48.png" "$LOGO_DIR/icons/distributor-logo.png"
cp "$LOGO_DIR/icons/auraos-logo-256.png" "$LOGO_DIR/icons/start-here.png"

echo "========================================="
echo " ✅ Logo entegrasyonu tamamlandı!"
echo "========================================="
