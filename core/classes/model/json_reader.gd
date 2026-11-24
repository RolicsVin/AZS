## Безопасное чтение типизированных полей из словаря, полученного из JSON. 
## Ошибки не прерывают работу, а записываются в переданный список. 
class_name JsonReader extends RefCounted


## Читает целое число из диапазона; нет ключа или ошибка — возвращает fallback
static func read_int(
		source: Dictionary,
		key: String,
		fallback: int,
		min_value: int,
		max_value: int,
		errors: Array[String]
) -> int:
	if not source.has(key):
		return fallback
	var value: Variant = source[key] ## Значение поля как есть
	if typeof(value) != TYPE_FLOAT and typeof(value) != TYPE_INT:
		errors.append('Поле «%s» должно быть числом.' % key)
		return fallback
	var number: float = float(value) ## JSON хранит все числа как float
	if number != floorf(number):
		errors.append('Поле «%s» должно быть целым числом.' % key)
		return fallback
	if number < float(min_value) or number > float(max_value):
		errors.append('Поле «%s» вне диапазона %d..%d.' % [key, min_value, max_value])
		return fallback
	return int(number)


## Читает число с плавающей точкой из диапазона; ошибка — возвращает fallback
static func read_float(
		source: Dictionary,
		key: String,
		fallback: float,
		min_value: float,
		max_value: float,
		errors: Array[String]
) -> float:
	if not source.has(key):
		return fallback
	var value: Variant = source[key] ## Значение поля как есть
	if typeof(value) != TYPE_FLOAT and typeof(value) != TYPE_INT:
		errors.append('Поле «%s» должно быть числом.' % key)
		return fallback
	var number: float = float(value) ## Число из файла
	if number < min_value or number > max_value:
		errors.append('Поле «%s» вне диапазона %s..%s.' % [key, min_value, max_value])
		return fallback
	return number


## Читает строку; для обязательного поля пустая строка считается ошибкой
static func read_string(
		source: Dictionary,
		key: String,
		fallback: String,
		is_required: bool,
		errors: Array[String]
) -> String:
	if not source.has(key):
		if is_required:
			errors.append('Не задано обязательное поле «%s».' % key)
		return fallback
	var value: Variant = source[key] ## Значение поля как есть
	if typeof(value) != TYPE_STRING:
		errors.append('Поле «%s» должно быть строкой.' % key)
		return fallback
	var text: String = value ## Строка из файла
	if is_required and text.strip_edges().is_empty():
		errors.append('Поле «%s» не должно быть пустым.' % key)
		return fallback
	return text
