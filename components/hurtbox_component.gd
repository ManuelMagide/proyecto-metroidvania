class_name HurtboxComponent
extends Area2D
## Componente receptor de impactos. Detecta HitboxComponents y aplica el daño al HealthComponent.

signal hit_received(hitbox: HitboxComponent)

@export var health_component: HealthComponent
@export var is_invincible: bool = false


func _ready() -> void:
	# Configuración correcta de detección para Godot 4:
	# monitoring = true permite detectar las Hitbox que entran en su área.
	# monitorable = false evita que otras Hurtboxes la detecten a ella.
	monitoring = true
	monitorable = false
	
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if is_invincible:
		return

	if area is HitboxComponent:
		var hitbox: HitboxComponent = area as HitboxComponent
		
		if health_component:
			health_component.take_damage(hitbox.damage)
		
		hit_received.emit(hitbox)


## Método auxiliar para activar/desactivar invulnerabilidad temporal (ej. tras recibir daño)
func set_invincible(duration: float) -> void:
	is_invincible = true
	await get_tree().create_timer(duration).timeout
	is_invincible = false
