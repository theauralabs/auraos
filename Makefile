.PHONY: all clean stable testing unstable snapshot prerelease release help check-stage logo

# Versiyon bilgileri
VERSION_YEAR = 26
BRANCH ?= stable
STAGE ?= snapshot
COUNTER ?= 1
DESKTOP ?= kde

# Tarih bilgileri
BUILD_DATE = $(shell date +%Y%m%d)
BUILD_TIME = $(shell date +%H%M%S)

# Renk kodları
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m

# Logo kontrolü ve oluşturma
logo:
	@echo "$(BLUE)Logo entegrasyonu başlatılıyor...$(NC)"
	@bash scripts/logo-integration.sh

# Stage kontrolü
check-stage:
	@if [ "$(STAGE)" = "prerelease" ]; then \
		if [ ! -f "build/$(BRANCH)/.snapshot-done" ]; then \
			echo "$(RED)HATA: PreRelease için önce Snapshot oluşturulmalı!$(NC)"; \
			exit 1; \
		fi \
	elif [ "$(STAGE)" = "release" ]; then \
		if [ ! -f "build/$(BRANCH)/.prerelease-done" ]; then \
			echo "$(RED)HATA: Release için önce PreRelease oluşturulmalı!$(NC)"; \
			exit 1; \
		fi \
	fi

all: help

# Ana build hedefleri
stable: check-stage logo
	@echo "$(GREEN)Building AuraOS Stable...$(NC)"
	@bash scripts/build-iso.sh stable $(STAGE) $(COUNTER) $(DESKTOP)

testing: check-stage logo
	@echo "$(GREEN)Building AuraOS Testing...$(NC)"
	@bash scripts/build-iso.sh testing $(STAGE) $(COUNTER) $(DESKTOP)

unstable: check-stage logo
	@echo "$(GREEN)Building AuraOS Unstable...$(NC)"
	@bash scripts/build-iso.sh unstable $(STAGE) $(COUNTER) $(DESKTOP)

# Stage hedefleri
snapshot: logo
	@echo "$(YELLOW)Building $(BRANCH) Snapshot-$(COUNTER)...$(NC)"
	@bash scripts/build-iso.sh $(BRANCH) snapshot $(COUNTER) $(DESKTOP)
	@touch build/$(BRANCH)/.snapshot-done

prerelease: check-stage logo
	@echo "$(YELLOW)Building $(BRANCH) PreRelease-$(COUNTER)...$(NC)"
	@bash scripts/build-iso.sh $(BRANCH) prerelease $(COUNTER) $(DESKTOP)
	@touch build/$(BRANCH)/.prerelease-done

release: check-stage logo
	@echo "$(GREEN)Building $(BRANCH) Release...$(NC)"
	@bash scripts/build-iso.sh $(BRANCH) release $(COUNTER) $(DESKTOP)
	@rm -f build/$(BRANCH)/.snapshot-done build/$(BRANCH)/.prerelease-done

# Temizlik
clean:
	@echo "$(YELLOW)Temizleniyor...$(NC)"
	@rm -rf build/*/chroot
	@rm -rf build/*/binary*
	@rm -f build/*/.snapshot-done build/*/.prerelease-done
	@rm -f *.iso
	@echo "$(GREEN)Temizleme tamamlandı!$(NC)"

# Yardım
help:
	@echo ""$(BLUE)==================$(NC)""
	@echo ""$(BLUE)     AURA OS      $(NC)""
	@echo ""$(BLUE)==================$(NC)""
	@echo "$(GREEN)======================================$(NC)"
	@echo "$(GREEN) AuraOS Build System - Aurora 2026$(NC)"
	@echo "$(GREEN)======================================$(NC)"
	@echo ""
	@echo "$(YELLOW)Kullanım:$(NC)"
	@echo "  make [hedef] [parametreler]"
	@echo ""
	@echo "$(YELLOW)Ana Hedefler:$(NC)"
	@echo "  make stable    - Stable branch derle"
	@echo "  make testing   - Testing branch derle"
	@echo "  make unstable  - Unstable branch derle"
	@echo ""
	@echo "$(YELLOW)Stage Hedefleri:$(NC)"
	@echo "  make snapshot   - Snapshot derle"
	@echo "  make prerelease - PreRelease derle"
	@echo "  make release    - Release derle"
	@echo ""
	@echo "$(YELLOW)Yardımcı:$(NC)"
	@echo "  make logo      - Logo varyasyonlarını oluştur"
	@echo "  make clean     - Build dosyalarını temizle"
	@echo "  make help      - Bu yardım mesajı"
	@echo ""
	@echo "$(YELLOW)Parametreler:$(NC)"
	@echo "  BRANCH=stable|testing|unstable (varsayılan: stable)"
	@echo "  STAGE=snapshot|prerelease|release (varsayılan: snapshot)"
	@echo "  COUNTER=1|2|3... (varsayılan: 1)"
	@echo "  DESKTOP=kde|gnome|xfce (varsayılan: kde)"
	@echo ""
	@echo "$(RED)⚠️  Süreç Sırası: snapshot → prerelease → release$(NC)"
	@echo ""
