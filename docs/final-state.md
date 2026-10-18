# Итоговое состояние системы (final-state)

> **Предостережение:** точное состояние, при котором игра стабильно запускается, **не воспроизведено на чистом префиксе**. В разделе «Подтверждено логами» указано только то, что зафиксировано в логах и процессах. В разделе «Предположения» — не проверенные гипотезы.

## Версии программного обеспечения

| Компонент | Версия | Источник |
|-----------|--------|----------|
| Ядро Linux | 7.2.10-arch1-1 | `uname -r` |
| Wine/Proton | GE-Proton-latest (GE-Proton11-9) | `~/.config/heroic/tools/proton/` |
| majestic-linux-runner-git | r86.765b2b7-1 (AUR) | `pacman -Qi majestic-linux-runner-git` |
| Majestic Launcher | 6.1.28 | `resources/app.asar/package.json` |
| Heroic Games Launcher | 2.22.4 Hajrudin | лог запуска Heroic |
| Rockstar Games Launcher | 1.0.109.3031 | `launcher.log`, `prelauncher.log` |
| Epic Games Launcher | 20.3.3 | установлен через MSI в префиксе |

## Дерево папок с размерами

### `~/Games/GTAV/` (список ключевых файлов)

| Файл | Тип | Размер | sha256sum |
|------|-----|--------|-----------|
| `GTA5.exe` | файл | 46 МБ | не вычислен |
| `PlayGTAV.exe` | файл | 560 КБ | не вычислен |
| `GTAVLauncher.exe` | symlink → `PlayGTAV.exe` | — | — |
| `GTA5_BE.exe` | файл | ~1,4 МБ | не вычислен |
| `EOSSDK-Win64-Shipping.dll` | файл | 9,6 МБ | не вычислен |

> **Примечание:** в момент успешного запуска `GTAVLauncher.exe` был симлинком на `PlayGTAV.exe`. В процессе экспериментов он временно заменялся на Windows-обёртку и на симлинк на `GTA5.exe`, но целевое состояние — симлинк на `PlayGTAV.exe`.

### Префикс Wine: `~/Games/Heroic/Prefixes/Grand Theft Auto V/drive_c/Program Files/Rockstar Games/Launcher/`

| Файл | Размер | sha256sum | Примечание |
|------|--------|-----------|------------|
| `Launcher.exe` | 29 920 888 | `d47e8c82c6b422724ab89866cd635ba247c50290ec70ac2bf765518e4af894cf` | Оригинал, сохранён как `Launcher_real.exe` |
| `LauncherPatcher.exe` | 1 208 952 | `1653347652b315e5bca950650fdddc43750029484bb2c26cbf95c1cd1ca8578f` | Оригинал |
| `Launcher_real.exe` | 29 920 888 | `d47e8c82c6b422724ab89866cd635ba247c50290ec70ac2bf765518e4af894cf` | Бэкап оригинального `Launcher.exe` |

> **Примечание:** в процессе экспериментов `Launcher.exe` временно заменялся на Windows-обёртку (~150 КБ), которая перезапускала `Launcher_real.exe` через `C:\windows\command\EpicGamesLauncher.exe`. Этот вариант не дал стабильного результата и не входит в целевое состояние.

### `~/Games/Heroic/Prefixes/Grand Theft Auto V/dosdevices/`

| Симлинк | Целевой путь |
|---------|--------------|
| `g:` | `$HOME/Games/GTAV` |
| `z:` | `/` |

### Симлинк префикса раннера

| Симлинк | Целевой путь |
|---------|--------------|
| `~/Games/majestic-gtav/271590` | `$HOME/Games/Heroic/Prefixes/Grand Theft Auto V` |

## Настройки Heroic

В `GamesConfig` для GTA V (`9d2d0eb64d5c44529cece33fe2a46482.json`) установлен `targetExe` — путь к `Majestic Launcher.exe` в префиксе (альтернативный EXE). Heroic запускает игру через `umu_run.py` → `proton waitforexitandrun` с `USE_FAKE_EPIC_EXE=true` и заглушкой `C:\windows\command\EpicGamesLauncher.exe`.

## Конфиг раннера

См. `config/majestic-runner.conf`. Пути замаскированы (`$HOME` вместо `/home/mishos`).

## Что реально решило проблему

### Подтверждено логами

1. Rockstar Launcher запускается и принимает `C:\windows\command\EpicGamesLauncher.exe` как родительский процесс (строка `Epic Games Launcher not detected as parent process` отсутствует, когда используется stub).
2. `GTAVLauncher.exe` как симлинк на `PlayGTAV.exe` — исходное состояние, при котором игра запускалась через цепочку Epic → Rockstar → GTA.
3. `GTA5_BE.exe` как симлинк на `GTA5.exe` — позволяет обойти BattlEye (который не работает на Linux).

### Предположения (не проверены на чистом префиксе)

- Точная команда, с которой `GTAVLauncher.exe` стартует Rockstar Launcher, неизвестна.
- Неизвестно, передаёт ли патчер Majestic аргументы `-skipPatcherCheck -epicAppId=gta5` корректно при использовании обёрток.
- Неизвестно, почему после перезагрузки компьютера цепочка перестаёт работать без повторной настройки.

## Что из правок оказалось НЕ нужно

| Права | Результат |
|-------|-----------|
| Обёртка `Launcher.exe` (~150 КБ) | Вызывала цикл `--real --real`, игра не запускалась |
| Обёртка `LauncherPatcher.exe` | Вызывала ту же проблему |
| `GTAVLauncher.exe → GTA5.exe` | Выдавала ошибку «запустите через Rockstar Games Launcher» |
| `MAJESTIC_PROTON_NATIVE_PLATFORM=rgl` | Вызывало цикл `--real --real` |
| `fix.bat` + кастомный `EpicGamesLauncher.exe` в папке игры | Не помогали, патчер не использует их |
| `USE_FAKE_EPIC_EXE=true` при запуске Majestic напрямую | Не влиял на внутренний вызов Rockstar из патчера |

## История противоречий

1. **`GTAVLauncher.exe`:** изначально был симлинком на `PlayGTAV.exe`. В процессе экспериментов заменялся на Windows-обёртку, затем на симлинк на `GTA5.exe`, затем обратно на `PlayGTAV.exe`. Целевое состояние — симлинк на `PlayGTAV.exe`.
2. **`Launcher.exe`:** изначально был настоящим 30-МБ файлом Rockstar. Временно заменялся на обёртку (~150 КБ), которая вызывала цикл `--real --real`.
3. **`LauncherPatcher.exe`:** временно заменялся на обёртку, вызывавшую ту же проблему.

## Неизвестное

- Почему игра запускалась один раз через чужой Epic Games Launcher (AppImage) и перестала после перезагрузки.

## Запуск без Heroic

Проверено: Heroic Games Launcher **не нужен при запуске** — игра стартует через `majestic-linux run` при закрытом Heroic. Heroic требуется только для первой установки (скачивание файлов GTA V из EGS, создание префикса, установка Rockstar Launcher и Social Club, GE-Proton).

Поскольку Heroic не нужен при запуске, в настройках GTA V в Heroic можно убрать «alternative exe» (`targetExe` → путь к `Majestic Launcher.exe`). Сам Heroic **удалять не стоит** — через него обновляются и проверяются файлы игры.

## Почему Epic открывается сам после «Играть»

Зафиксировано в `ps --forest` (process-tree-final.log). При нажатии «Играть» Heroic запускает Majestic Launcher через:

```
umu_run.py C:\windows\command\EpicGamesLauncher.exe ...\Majestic Launcher.exe -AUTH_LOGIN=unused -AUTH_PASSWORD=...
```

То есть `C:\windows\command\EpicGamesLauncher.exe` (заглушка из-за `USE_FAKE_EPIC_EXE=true`) передаётся в `umu_run.py` как исполняемый файл, а Majestic Launcher — как аргумент. Далее в цепочке Proton/Wine:

```
start.exe /exec C:\windows\command\EpicGamesLauncher.exe ...\Majestic Launcher.exe ...
```

`start.exe /exec` на самом деле запускает `EpicGamesLauncher.exe` как отдельный Windows-процесс (PID 38979 в логе, ребёнок pressure-vessel/proton-цепочки, PPID не Majestic). Поэтому окно Epic Games Launcher появляется само — не Majestic его вызывает, а цепочка запуска Proton/Wine, iniciрованная Heroic с `targetExe` = Majestic Launcher и `USE_FAKE_EPIC_EXE=true`.
