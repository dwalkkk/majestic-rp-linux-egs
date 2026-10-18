# Majestic RP на Linux с Epic-версией GTA V (Heroic)

> **Неофициальный репозиторий.** Не связан с Majestic Role Play, Rockstar Games, Epic Games и Heroic Games Launcher. Все торговые марки принадлежат их владельцам. Здесь только документация, пример конфига и скрипт проверки состояния. Бинарники игр и лаунчеров не распространяются.

## Статус

**Работает у одного человека на одной системе. На чистой установке не воспроизводилось.** Многие причины ниже установлены по логам, но не проверены повторным тестом. Где это так, написано «предположение».

Система автора: Arch Linux, GE-Proton 11-9, GTA V Legacy из Epic Games Store, установленная через Heroic.

## Задача

Majestic Launcher существует только под Windows. Есть неофициальный раннер [majestic-rp-linux](https://github.com/digitalhorizongroup/majestic-rp-linux) (команда `majestic-linux`), который запускает его через Proton. Он поддерживает Steam, Rockstar Games Launcher и EGS, но с Epic-версией GTA V из Heroic «из коробки» у автора не заработало: Majestic Launcher открывался, а игра при нажатии «Играть» не стартовала.

## Как это устроено (по логам)

1. Majestic Launcher определяет платформу GTA как `epic` (`gtaPlatform: 'epic'` в его `main.log`).
2. При нажатии «Играть» он запускает свой патчер (`launch-config.json` в `drive_c/users/steamuser/AppData/Local/Temp`). Патчер ждёт, пока Rockstar Games Launcher запустит игру.
3. У Epic-версии GTA V Rockstar Launcher проверяет, что его запустил Epic Games Launcher. Если нет, он пишет в `Documents/Rockstar Games/Launcher/launcher.log`:
   - `Epic Games Launcher not detected as parent process`
   - `Relaunch from third party platform required`
   - `Shutting down to request third-party min-mode launch`

   и завершается. Патчер Majestic ждёт 180 секунд и падает с `ERR_TIMEOUT` (в лаунчере «Запуск занял слишком много времени…»).
4. Heroic запускает игру через заглушку `C:\windows\command\EpicGamesLauncher.exe` и `PlayGTAV.exe`. Для обычной игры этого хватает, для цепочки через патчер Majestic, по-видимому, нет (предположение).
5. Когда в том же префиксе работает настоящий Epic Games Launcher, цепочка Epic → Rockstar → `GTA5_BE.exe` проходит нормально (подтверждено логом: Rockstar Launcher запускает `GTA5_BE.exe` с `-epicAppId=gta5`, без «not detected as parent process»).

## Что стояло в рабочем состоянии

Подробности и проверка: [`docs/final-state.md`](docs/final-state.md), [`scripts/check-state.sh`](scripts/check-state.sh).

- Раннер использует **префикс Heroic** (не отдельный). Путь к нему задан через симлинк, **который обязательно заканчивается числом**, например `~/Games/majestic-gtav/271590` → префикс Heroic (внутри должна быть папка `pfx`). Без числа в пути ProtonFixes падает (`IndexError`).
- В префиксе установлен **настоящий Epic Games Launcher** (версия 20.3.3 в логах).
- **Настоящие файлы Rockstar Launcher**, без обёрток:
  - `Launcher.exe`, 29 920 888 байт, sha256 `d47e8c82c6b422724ab89866cd635ba247c50290ec70ac2bf765518e4af894cf`, версия 1.0.109.3031
  - `LauncherPatcher.exe`, 1 208 952 байта, sha256 `1653347652b315e5bca950650fdddc43750029484bb2c26cbf95c1cd1ca8578f`
- В папке игры симлинки на `GTA5.exe`: `GTAVLauncher.exe` (создаёт раннер) и `GTA5_BE.exe` (Rockstar запускает именно его, не удаляй).
- `MAJESTIC_PLATFORM=auto`, `MAJESTIC_PROTON_NATIVE_PLATFORM` пусто. Пример: [`config/majestic-runner.conf`](config/majestic-runner.conf).

## Запуск

```bash
# остатки прошлых процессов в префиксе
WINEPREFIX="$HOME/Games/Heroic/Prefixes/Grand Theft Auto V" wineserver -k

majestic-linux run
```

Heroic при этом **не запускается и не нажимается**. Он нужен только для первой установки: через него скачиваются файлы GTA V из Epic Games Store, создаётся префикс `…/Heroic/Prefixes/Grand Theft Auto V` и ставятся Rockstar Launcher с Social Club, а также используется GE-Proton из `~/.config/heroic/tools/proton`. Вход в Epic выполнялся вручную в окне настоящего Epic Games Launcher внутри префикса, авторизация Heroic (legendary) не используется. При запуске Heroic не нужен: проверено, игра запустилась при закрытом Heroic. Если в Heroic для GTA V когда-то выбирали «alternative exe» с Majestic, это значение нужно убрать.

Дальше в Majestic войти и нажать «Играть». У автора Epic Games Launcher после этого **открывается сам**. Почему, точно не выяснено (предположение: его стартует цепочка запуска или его автозапуск в префиксе).

Установка Epic Games Launcher в префикс и первый запуск описаны в [`docs/timeline.md`](docs/timeline.md). Важное:

- exe-установщик Epic в Wine падает с «MSI payload failed signature verification». Ставить нужно **MSI напрямую**: `proton run msiexec /i EpicInstaller-*.msi`.
- Первый запуск Epic обновляет себя; без окна он остаётся, пока самообновление не закончится. Запускать из `Program Files/Epic Games/Launcher/Portal/Binaries/Win64/EpicGamesLauncher.exe` без флага `-opengl`.

## Ошибки и что их вызывало

Подробная хронология: [`docs/timeline.md`](docs/timeline.md).

| Симптом | Причина | Решение | Статус |
|---|---|---|---|
| `IndexError: list index out of range` в `protonfixes/fix.py` | В `STEAM_COMPAT_DATA_PATH` нет цифр | Путь вида `…/271590` | подтверждено |
| `Majestic installer exited with code 1` за 3 с | Файл установщика нулевого размера | Удалить файл, запустить `install` заново | подтверждено |
| `winetricks … version mismatch 938/962` | Системный Wine и wineserver от Proton разных версий | Раннер продолжает работу, на запуск не влияло | наблюдалось, влияние не выяснено |
| «Запустите GTA V с помощью Rockstar Games Launcher» | Majestic запускает `GTA5.exe`, а Epic-версии нужен Rockstar Launcher | Настоящий Epic в префиксе | подтверждено сообщением, причина по логам |
| `Epic Games Launcher not detected as parent process`, потом `ERR_TIMEOUT` через 180 с | Нет настоящего Epic Games Launcher (заглушка Heroic не подходит) | Установить и запустить настоящий Epic | подтверждено логами |
| «MSI payload failed signature verification» | Особенность exe-установщика Epic в Wine | Устанавливать MSI | подтверждено |
| У Epic нет окна, `EpicGamesUpdater … StartServiceFailed (code 8)` | После самообновления лаунчер не перезапускается | В итоге заработал после обновления до 20.3.3 | причина **предположение** |
| Крэш Epic: `Assertion failed: PixelFormat … SlateOpenGLContext.cpp` | Флаг `-opengl` | Не использовать | подтверждено |
| Цикл `--real --real` в `launcher.log` | Самодельная обёртка `Launcher.exe` вызывала `Launcher_real.exe` по кругу | Обёртки не нужны, вернуть настоящие файлы | подтверждено логами |
| `Launcher_real.exe` и другие файлы пропадают, `Launcher.exe` становится настоящим | `LauncherPatcher.exe` переустанавливает Rockstar Launcher | Держать копию рабочих файлов | механизм — **предположение** |

## Чего мы не знаем

- Почему патчер получает `"gtaPlatform": "rgl"` в `launch-config.json`, хотя в `main.log` написано `epic`. Возможно, это внутреннее название режима «через Rockstar Launcher».
- Почему Epic открывается сам после «Играть».
- Какие из изменений в префиксе были нужны, а какие нет. Тестов на чистом префиксе не делалось.
- Устойчивость к обновлениям Rockstar Launcher, Epic, Majestic и раннера.

## Чего делать не стоит

- Не подменять `Launcher.exe` и `LauncherPatcher.exe` обёртками: это приводило к зацикливанию.
- Не запускать Epic с `-opengl`.
- Не публиковать логи без очистки: в них встречаются токены Epic и Majestic, `AUTH_PASSWORD`, `epicuserid`.
- Не использовать `Launcher.exe` версии 108, он обновляется сам (`-upgrade`) и перезаписывает файлы.

## Проверка и откат

```bash
scripts/check-state.sh   # только читает, ничего не меняет
```

Если что-то сломалось после обновления, сравни хеши `Launcher.exe` и `LauncherPatcher.exe` с таблицей выше и пришли `launcher.log` (Rockstar) и `logs/main.log` (Majestic) без токенов.

## Лицензия

MIT. См. [`LICENSE`](LICENSE).
