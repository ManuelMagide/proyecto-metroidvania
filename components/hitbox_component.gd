class_name HitboxComponent
extends Area2D
## Componente encargado de definir una zona ofensiva (ataques, proyectiles, trampas).

@export var damage: int = 1
@export var knockback_force: float = 0.0

func _ready() -> void:
	# Asegura que la Hitbox sea detectable por la Hurtbox
	monitoring = false  # No necesita detectar otras áreas por sí misma
	monitorable = true  # Permite ser detectada por un HurtboxComponent
