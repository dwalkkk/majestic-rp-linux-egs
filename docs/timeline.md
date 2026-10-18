# Хронология ошибок и попыток их решения

| # | Действие | Ошибка | Причина | Подтверждена? | Что решило |
|---|----------|--------|---------|---------------|------------|
| 1 | `majestic-linux doctor`, `majestic-linux run` (отдельный префикс) | Игра не запускается, `analyze-crash: Analyzed logs: 0` | В префиксе нет Rockstar Games Launcher | Предположение | Перенос на префикс Heroic |
| 2 | Симлинк `gtav-prefix` (без цифр) | `IndexError: list index out of range` в `protonfixes/fix.py: get_game_id()` | `re.findall(r'\d+')[-1]` не находит цифры в пути | Подтверждена (код) | Переименование в `271590` |
| 3 | `MajesticLinuxSetup.exe` нулевого размера | `Majestic installer exited with code 1` | Остаток неудавшегося скачивания | Подтверждена | Удаление файла, повторная установка |
| 4 | `winetricks -q win10` | `wine client error:0: version mismatch 938/962` | winetricks вызывает системный wine, а wineserver от Proton-GE | Подтверждена | Fallback на direct registry edit |
| 5 | `EpicInstaller-20.3.3.exe` | `Certificate CN does not match 'Epic Games Inc.'` | Эмбетный MSI payload не проходит проверку подписи | Подтверждена | Установка MSI напрямую: `msiexec /i` |
| 6 | Запуск Epic Games Launcher в Wine | Окно не открывается, `StartServiceFailed` (code 8) | Служба перезапуска не стартует в Wine | Подтверждена (логи) | Не решено |
| 7 | Запуск Epic с `-opengl` | `Assertion failed: PixelFormat ... SlateOpenGLContext.cpp, Line 100` | Unreal Crash Reporter | Предположение | Не решено |
| 8 | `DxvkInstance::createInstance: Failed to create Vulkan instance` | Один из запусков Epic | Неизвестно | Предположение | Не решено |
| 9 | Heroic + Majestic, нажатие «Играть» | `ERR_TIMEOUT` после 180 сек | Rockstar Launcher не находит Epic как родитель | Подтверждена (логи: `Epic Games Launcher not detected as parent process`) | Не решено стабильно |
| 10 | Обёртка `Launcher.exe` → `Launcher_real.exe` через Epic stub | Цикл `--real --real`, игра не запускается | Обёртка добавляет `--real`, Rockstar перезапускает себя с ещё одним `--real` | Подтверждена (логи, исходник обёртки) | Удаление обёртки |
| 11 | `GTAVLauncher.exe → GTA5.exe` | Ошибка «запустите GTA V с помощью Rockstar Games Launcher` | Патчер ожидает `GTAVLauncher.exe` как точку входа Rockstar | Подтверждена | Возврат на `PlayGTAV.exe` |
| 12 | `MAJESTIC_PROTON_NATIVE_PLATFORM=rgl` | Цикл `--real --real` | Нативный патчер использует `GTAVLauncher.exe` напрямую | Подтверждена | Возврат к пустому значению |

## Ключевые лог-фрагменты

### Rockstar Launcher: «Epic Games Launcher not detected as parent process»
```
[external] Creating epic min mode launch
[external] Epic Games Launcher not detected as parent process.
[startup] Relaunch from third party platform required
[startup] Shutting down to request third-party launch
```

### Мажestic патчер: таймаут
```
patcher: timeout — killing worker { timeoutMs: 180000 }
pipeline completed { success: false, error: 'ERR_TIMEOUT' }
game launch failed { serverId: 'ru18', reason: 'timeout', message: 'ERR_TIMEOUT' }
```

### Epic Games Launcher: StartServiceFailed
```
Application finished with code 8 (StartServiceFailed)
```

### winetricks version mismatch
```
wine client error:0: version mismatch 938/962
```
