#!/bin/bash
set -e

# Parametreler
BRANCH=${1:-stable}
STAGE=${2:-snapshot}
COUNTER=${3:-1}
DESKTOP=${4:-kde}

# Versiyon hesaplama
case $BRANCH in
    stable)
        VERSION="26.1"
        DEBIAN_SUITE="trixie"
        ;;
    testing)
        if [ "$(date +%m)" -le "06" ]; then
            VERSION="26.1"
        else
            VERSION="26.2"
        fi
        DEBIAN_SUITE="testing"
        ;;
    unstable)
        MONTH=$(date +%m)
        if [ "$MONTH" -le "03" ]; then
            VERSION="26.1"
        elif [ "$MONTH" -le "06" ]; then
            VERSION="26.2"
        elif [ "$MONTH" -le "09" ]; then
            VERSION="26.3"
        else
            VERSION="26.4"
        fi
        DEBIAN_SUITE="sid"
        ;;
esac

# Build adı oluştur
if [ "$STAGE" = "release" ]; then
    BUILD_NAME="${VERSION}-${BRANCH}-${STAGE}"
else
    BUILD_NAME="${VERSION}-${BRANCH}-${STAGE}-${COUNTER}"
fi

DATE=$(date +%Y%m%d)

echo ""
echo " AURA OS "
echo ""
echo "========================================="
echo " AuraOS Build System"
echo " Codename: Aurora (2026)"
echo "========================================="
echo " Branch: $BRANCH"
echo " Stage: $STAGE"
echo " Version: $VERSION"
echo " Counter: $COUNTER"
echo " Desktop: $DESKTOP"
echo " Build: $BUILD_NAME"
echo "========================================="

# Build dizini hazırlık
cd build/$BRANCH

# Önceki build temizliği
if [ -d config ]; then
    sudo lb clean --purge || true
fi

# Live-build yapılandırması
lb config \
    --mode debian \
    --architectures amd64 \
    --distribution $DEBIAN_SUITE \
    --archive-areas "main contrib non-free non-free-firmware" \
    --debian-installer live \
    --debian-installer-gui true \
    --debian-installer-distribution $DEBIAN_SUITE \
    --iso-application "AuraOS" \
    --iso-volume "AuraOS_${BUILD_NAME}" \
    --iso-publisher "TheAuraLabs" \
    --iso-preparer "AuraOS Build System" \
    --bootappend-live "boot=live components quiet splash" \
    --bootappend-install "quiet splash" \
    --mirror-bootstrap "http://deb.debian.org/debian/" \
    --mirror-chroot "http://deb.debian.org/debian/" \
    --mirror-binary "http://deb.debian.org/debian/" \
    --security true \
    --updates true \
    --backports false \
    --firmware-chroot true \
    --firmware-binary true \
    --memtest memtest86+

# Masaüstü ortamı paketleri
mkdir -p config/package-lists

case $DESKTOP in
    kde)
        cat > config/package-lists/desktop.list.chroot << PACKAGES
task-kde-desktop
kde-plasma-desktop
plasma-nm
konsole
dolphin
kate
ark
spectacle
okular
gwenview
firefox-esr
thunderbird
libreoffice
libreoffice-kde5
PACKAGES
        ;;
    gnome)
        cat > config/package-lists/desktop.list.chroot << PACKAGES
task-gnome-desktop
gnome-shell
gnome-terminal
nautilus
gedit
file-roller
gnome-screenshot
evince
eog
firefox-esr
thunderbird
libreoffice
libreoffice-gnome
PACKAGES
        ;;
    xfce)
        cat > config/package-lists/desktop.list.chroot << PACKAGES
task-xfce-desktop
xfce4
xfce4-terminal
thunar
mousepad
xarchiver
xfce4-screenshooter
atril
ristretto
firefox-esr
thunderbird
libreoffice
libreoffice-gtk3
PACKAGES
        ;;
esac

# Temel sistem paketleri
cat > config/package-lists/base.list.chroot << 'PACKAGES'
linux-image-amd64
grub-efi-amd64
grub-pc-bin
network-manager
network-manager-gnome
firmware-linux
firmware-linux-nonfree
firmware-misc-nonfree
neofetch
htop
git
curl
wget
vim
nano
build-essential
apt-transport-https
ca-certificates
gnupg
lsb-release
plymouth
plymouth-themes
os-prober
ntfs-3g
exfat-fuse
exfat-utils
PACKAGES

# Branding ve özelleştirmeler
if [ "$STAGE" != "snapshot" ]; then
    echo "🎨 Branding ekleniyor..."
    
    # Dizinleri oluştur
    mkdir -p config/includes.chroot/usr/share/backgrounds
    mkdir -p config/includes.chroot/usr/share/pixmaps
    mkdir -p config/includes.chroot/usr/share/plymouth/themes/auraos
    mkdir -p config/includes.chroot/etc/skel
    mkdir -p config/includes.chroot/etc/default
    
    # Logo ve wallpaper kopyala
    if [ -f "../../branding/wallpapers/auraos-wallpaper.png" ]; then
        cp ../../branding/wallpapers/auraos-wallpaper.png \
           config/includes.chroot/usr/share/backgrounds/
    fi
    
    if [ -f "../../branding/icons/auraos-logo-256.png" ]; then
        cp ../../branding/icons/auraos-logo-256.png \
           config/includes.chroot/usr/share/pixmaps/auraos-logo.png
    fi
    
    # Plymouth tema
    if [ -f "../../branding/plymouth/auraos-logo.png" ]; then
        cp ../../branding/plymouth/auraos-logo.png \
           config/includes.chroot/usr/share/plymouth/themes/auraos/
           
        cat > config/includes.chroot/usr/share/plymouth/themes/auraos/auraos.plymouth << 'PLYMOUTH'
[Plymouth Theme]
Name=AuraOS
Description=AuraOS Boot Theme
ModuleName=script

[script]
ImageDir=/usr/share/plymouth/themes/auraos
ScriptFile=/usr/share/plymouth/themes/auraos/auraos.script
PLYMOUTH

        cat > config/includes.chroot/usr/share/plymouth/themes/auraos/auraos.script << 'SCRIPT'
logo.image = Image("auraos-logo.png");
logo.sprite = Sprite(logo.image);
logo.x = Window.GetX() + Window.GetWidth()  / 2 - logo.image.GetWidth()  / 2;
logo.y = Window.GetY() + Window.GetHeight() / 2 - logo.image.GetHeight() / 2;
logo.sprite.SetPosition(logo.x, logo.y, 1);
SCRIPT
    fi
    
    # GRUB tema
    mkdir -p config/includes.chroot/boot/grub
    if [ -f "../../branding/grub/auraos-grub.png" ]; then
        cp ../../branding/grub/auraos-grub.png \
           config/includes.chroot/boot/grub/background.png
    fi
    
    # Sistem bilgileri dosyası
    cat > config/includes.chroot/etc/auraos-release << INFO
NAME="AuraOS"
VERSION="$VERSION"
ID=auraos
ID_LIKE=debian
PRETTY_NAME="AuraOS $VERSION ($BRANCH)"
VERSION_ID="$VERSION"
VERSION_CODENAME="aurora"
HOME_URL="https://github.com/theauralabs/auraos"
SUPPORT_URL="https://github.com/theauralabs/auraos/discussions"
BUG_REPORT_URL="https://github.com/theauralabs/auraos/issues"
INFO
fi

# Hooks dizini
mkdir -p config/hooks/live

# Özelleştirme hook'u
cat > config/hooks/live/01-auraos-branding.hook.chroot << 'HOOK'
#!/bin/sh
set -e

# AuraOS özelleştirmeleri
echo "AuraOS" > /etc/hostname

# MOTD
cat > /etc/motd << MOTD
 
  AURA OS
  Sade, Kararlı, Güçlü.
  
  GitHub: https://github.com/theauralabs/auraos
  
MOTD

# Plymouth varsayılan tema
if [ -d /usr/share/plymouth/themes/auraos ]; then
    plymouth-set-default-theme auraos
fi
HOOK

chmod +x config/hooks/live/01-auraos-branding.hook.chroot

# Build başlat
echo "🔨 Build başlatılıyor..."
sudo lb build

# ISO'yu yeniden adlandır ve taşı
ISO_NAME="AuraOS-${BUILD_NAME}-${DATE}-amd64.iso"
if [ -f live-image-amd64.hybrid.iso ]; then
    mv live-image-amd64.hybrid.iso ../../${ISO_NAME}
    echo "✅ ISO oluşturuldu: ${ISO_NAME}"
    echo "📦 Boyut: $(du -h ../../${ISO_NAME} | cut -f1)"
    
    # MD5 ve SHA256 hash
    cd ../..
    md5sum ${ISO_NAME} > ${ISO_NAME}.md5
    sha256sum ${ISO_NAME} > ${ISO_NAME}.sha256
    echo "🔒 Hash dosyaları oluşturuldu"
else
    echo "❌ ISO oluşturulamadı!"
    exit 1
fi

echo "========================================="
echo " ✅ Build tamamlandı!"
echo " ISO: ${ISO_NAME}"
echo "========================================="
