## Определяет финал игры по итоговым показателям.
## Не управляет сценами и не изменяет GameState.
class_name Endings extends RefCounted

const RICH: String = "rich"
const RESPECT: String = "respect"
const FAILURE: String = "failure"


## Деньги имеют приоритет, если игрок достиг обоих порогов.
func determine(
	money: int,
	respect: int,
	money_threshold: int,
	respect_threshold: int
) -> String:
	if money >= money_threshold:
		return RICH
	if respect >= respect_threshold:
		return RESPECT
	return FAILURE
