# Архитектура игровых систем АЗС

## Компоненты верхнего уровня

- **Game** — главный координатор и composition root.
- **SequenceController** — последовательность рабочих смен и элементов Work.
- **UIController** — отображение интерфейса и управление доступностью кнопок.
- **DecisionService** — обработка решений игрока и применение их последствий.
- **EventController** — координация применения и отображения игровых событий.
- **GameState** — состояние денег и репутации; текущий Autoload по-прежнему называется `Data`.

## Расположение систем

- `core/systems/sequence_controller.gd`
- `core/systems/ui_controller.gd`
- `core/systems/decision_service.gd`
- `core/systems/event_controller.gd`
- `core/systems/event_service.gd`
- `core/data.gd` — реализация GameState, Autoload-имя Data

## Сценарий решения

1. Game получает действие игрока.
2. DecisionService проверяет Car и получает результат `Car.calculate_decision()`.
3. GameState/Data применяет обе дельты через `apply_delta()` атомарно.
4. После успешного изменения DecisionService запускает визуальную реакцию Car.
5. Game запрашивает следующий элемент у SequenceController.

## Сценарий события

1. SequenceController выдаёт Event из Work.
2. EventController передаёт событие в EventService.
3. EventService проверяет ресурс и применяет числовой эффект через GameState/Data.
4. EventController поручает UIController показать текст события.
5. После продолжения игрока Game запрашивает следующий элемент.

## Данные и конфигурации

Существующие классы `Character`, `Car`, `Event`, `Work`, `LinearDialog` и `Choise` сохранены. Их экспортируемые поля и ссылки в сценах не заменяются контроллерами.

## Добавление события

1. Создайте ресурс типа Event.
2. Заполните `event_text`, `anim_name`, `money` и `respect`.
3. Сохраните ресурс в `res://content/events/`.
4. Добавьте ресурс в `sequence` нужного Work.

Подробная схема и контракты компонентов находятся в `docs/architecture.md`.
