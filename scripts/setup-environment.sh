#!/bin/bash
set -e

echo "========================================="
echo " AuraOS Geliştirme Ortamı Kurulumu"
echo " Codename: Aurora (2026)"
echo "========================================="

# Debian Trixie kaynaklarını ayarla
cat > /etc/apt/sources.list << SOURCES
deb http://deb.debian.org/debian/ trixie main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian/ trixie main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
deb-src http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
SOURCES

# Sistem güncelleme
apt-get update
apt-get upgrade -y

# Live-build ve gerekli araçlar
apt-get install -y \
    live-build \
    debootstrap \
    squashfs-tools \
    xorriso \
    grub-pc-bin \
    grub-efi-amd64-bin \
    mtools \
    dosfstools \
    genisoimage \
    isolinux \
    syslinux-common \
    git \
    curl \
    wget \
    build-essential \
    devscripts \
    debhelper \
    lsb-release \
    imagemagick \
    librsvg2-bin

echo "✅ Kurulum tamamlandı!"
echo "ℹ️  'make help' komutu ile başlayabilirsiniz."
