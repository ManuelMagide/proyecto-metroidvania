class_name HealthComponent
extends Node
## Componente desacoplado para gestionar la salud y el daño de cualquier entidad.

signal health_changed(new_health: int, max_health: int)
signal health_depleted

@export var max_health: int = 10:
	set(value):
		max_health = maxi(1, value)
		if is_node_ready():
			current_health = clampi(current_health, 0, max_health)
			health_changed.emit(current_health, max_health)

var current_health: int


func _ready() -> void:
	current_health = max_health


## Aplica daño a la entidad reduciendo la salud actual.
func take_damage(amount: int) -> void:
	if amount <= 0 or is_dead():
		return
		
	current_health = clampi(current_health - amount, 0, max_health)
	health_changed.emit(current_health, max_health)
	
	if current_health == 0:
		health_depleted.emit()


## Aplica curación a la entidad sin sobrepasar max_health.
func heal(amount: int) -> void:
	if amount <= 0 or current_health >= max_health or is_dead():
		return
		
	current_health = clampi(current_health + amount, 0, max_health)
	health_changed.emit(current_health, max_health)


## Restablece la salud al máximo (util para checkpoints / respawn).
func reset_health() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)


## Retorna true si la salud ha llegado a cero.
func is_dead() -> bool:
	return current_health == 0


## Retorna el porcentaje de salud actual de 0.0 a 1.0 (útil para barras de UI).
func get_health_percent() -> float:
	return float(current_health) / float(max_health)
