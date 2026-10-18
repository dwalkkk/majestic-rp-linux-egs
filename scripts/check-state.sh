#!/bin/bash
# check-state.sh — проверяет итоговое состояние системы для запуска Majestic RP
# НИЧЕГО не меняет, только читает и сравнивает.

set -euo pipefail

PREFIX="$HOME/Games/Heroic/Prefixes/Grand Theft Auto V"
GTAV="$HOME/Games/GTAV"
ROCKSTAR_LAUNCHER="$PREFIX/drive_c/Program Files/Rockstar Games/Launcher"

echo "=== Проверка состояния Majestic RP (Epic/EGS) ==="
echo ""

# 1. GTAVLauncher.exe должен быть symlink на PlayGTAV.exe
echo "[1/6] GTAVLauncher.exe → PlayGTAV.exe"
if [ -L "$GTAV/GTAVLauncher.exe" ]; then
    target=$(readlink "$GTAV/GTAVLauncher.exe")
    if [ "$target" = "PlayGTAV.exe" ]; then
        echo "  OK: symlink на PlayGTAV.exe"
    else
        echo "  FAIL: симлинк указывает на '$target', ожидалось 'PlayGTAV.exe'"
    fi
else
    echo "  FAIL: не симлинк (файл или отсутствует)"
fi
echo ""

# 2. GTA5_BE.exe должен быть настоящим файлом (~1.4 МБ)
echo "[2/6] GTA5_BE.exe — настоящий файл"
if [ -f "$GTAV/GTA5_BE.exe" ] && [ ! -L "$GTAV/GTA5_BE.exe" ]; then
    size=$(stat -c%s "$GTAV/GTA5_BE.exe" 2>/dev/null || echo "unknown")
    echo "  OK: файл, размер $size байт"
else
    echo "  FAIL: не является обычным файлом или отсутствует"
fi
echo ""

# 3. Launcher.exe — настоящий Rockstar (30 МБ)
echo "[3/6] Launcher.exe — настоящий файл (~30 МБ)"
if [ -f "$ROCKSTAR_LAUNCHER/Launcher.exe" ] && [ ! -L "$ROCKSTAR_LAUNCHER/Launcher.exe" ]; then
    size=$(stat -c%s "$ROCKSTAR_LAUNCHER/Launcher.exe" 2>/dev/null || echo "unknown")
    echo "  OK: файл, размер $size байт"
else
    echo "  FAIL: не является обычным файлом или отсутствует"
fi
echo ""

# 4. LauncherPatcher.exe — настоящий файл (~1.2 МБ)
echo "[4/6] LauncherPatcher.exe — настоящий файл (~1.2 МБ)"
if [ -f "$ROCKSTAR_LAUNCHER/LauncherPatcher.exe" ] && [ ! -L "$ROCKSTAR_LAUNCHER/LauncherPatcher.exe" ]; then
    size=$(stat -c%s "$ROCKSTAR_LAUNCHER/LauncherPatcher.exe" 2>/dev/null || echo "unknown")
    echo "  OK: файл, размер $size байт"
else
    echo "  FAIL: не является обычным файлом или отсутствует"
fi
echo ""

# 5. dosdevices g: → GTAV
echo "[5/6] dosdevices/g: → $GTAV"
if [ -L "$PREFIX/dosdevices/g:" ]; then
    target=$(readlink "$PREFIX/dosdevices/g:")
    if [ "$target" = "$GTAV" ]; then
        echo "  OK: симлинк на $GTAV"
    else
        echo "  FAIL: указывает на '$target', ожидалось '$GTAV'"
    fi
else
    echo "  FAIL: не симлинк или отсутствует"
fi
echo ""

# 6. Symlink префикса раннера
echo "[6/6] ~/Games/majestic-gtav/271590 → префикс Heroic"
if [ -L "$HOME/Games/majestic-gtav/271590" ]; then
    target=$(readlink "$HOME/Games/majestic-gtav/271590")
    if [ "$target" = "$PREFIX" ]; then
        echo "  OK: симлинк на $PREFIX"
    else
        echo "  FAIL: указывает на '$target', ожидалось '$PREFIX'"
    fi
else
    echo "  FAIL: не симлинк или отсутствует"
fi
echo ""

echo "Проверка завершена."
