# Игровые системы

Подробное описание архитектуры, схемы, форматов данных и обработки ошибок находится в
[docs/architecture.md](../../docs/architecture.md). Здесь только карта файлов.

| Файл | Роль |
|---|---|
| `content_loader.gd` | Читает и проверяет `content/content.json`, возвращает `ContentBundle` |
| `content_applier.gd` | Настраивает смены и вставляет события из набора |
| `sequence_controller.gd` | Выдаёт элементы смен по порядку (`SequenceEntry`) |
| `decision_service.gd` | Применяет решение игрока через `GameState` |
| `event_service.gd` | Проверяет событие и применяет его эффект |
| `event_controller.gd` | Применяет эффект события, затем показывает его |
| `ui_controller.gd` | Показывает экраны через `UIBindings`, управляет кнопками |
| `../data.gd` | `GameState` (автозагрузка `Data`): деньги и репутация |
