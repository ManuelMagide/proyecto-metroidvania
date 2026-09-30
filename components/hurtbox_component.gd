class_name HurtboxComponent
extends Area2D

## Referencia al componente de salud del objeto
@export var health_component: HealthComponent

func _ready() -> void:
	monitorable = true
	monitoring = false

## Recibe el daño enviado desde una Hitbox
func receive_damage(amount: int) -> void:
	if health_component:
		health_component.take_damage(amount)
