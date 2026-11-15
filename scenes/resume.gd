## Скрипт, для отображения резюме кандидата. 
extends Node3D


func set_text(text: String) -> void: ## Установит текст
	$Label3D.text = text
