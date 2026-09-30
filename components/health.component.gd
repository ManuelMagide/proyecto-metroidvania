class_name HealthComponent
extends Node

## Señales para notificar cambios de salud
signal health_changed(new_health: int, max_health: int)
signal died

@export var max_health: int = 10
var current_health: int

func _ready() -> void:
	current_health = max_health

## Aplica daño
func take_damage(amount: int) -> void:
	if amount <= 0:
		return
		
	current_health = max(0, current_health - amount)
	health_changed.emit(current_health, max_health)
	
	if current_health == 0:
		died.emit()

## Aplica curación
func heal(amount: int) -> void:
	if amount <= 0 or current_health >= max_health:
		return
		
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)
