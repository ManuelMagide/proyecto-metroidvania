extends CharacterBody2D
## Controlador cinemático 2D del jugador.
## Gestiona aceleración, fricción, salto regulable, coyote time y jump buffer.

signal state_changed(new_state: State)

enum State { IDLE, RUN, JUMP, FALL }

@export_group("Movimiento horizontal")
@export var max_speed: float = 160.0      # px/s
@export var acceleration: float = 1200.0  # px/s²
@export var friction: float = 1400.0      # px/s²

@export_group("Salto y gravedad")
@export var jump_velocity: float = -320.0 # px/s
@export var gravity: float = 900.0        # px/s²
@export var fall_multiplier: float = 1.4  # Multiplicador de caída
@export var max_fall_speed: float = 400.0 # Velocidad terminal
@export var jump_cut: float = 0.5         # Recorte de salto al soltar el botón

@export_group("Tolerancias (Game Feel)")
@export var coyote_time: float = 0.1      # Tiempo límite tras dejar una plataforma
@export var jump_buffer_time: float = 0.1 # Registro de entrada previa al suelo

var state: State = State.IDLE
var facing: int = 1  # 1 = derecha, -1 = izquierda

var _coyote_timer: float = 0.0
var _buffer_timer: float = 0.0


func _ready() -> void:
	add_to_group("player")
	# Verificamos si existe el componente de salud y escuchamos cuando cambia la vida
	if has_node("HealthComponent"):
		$HealthComponent.health_changed.connect(_on_health_changed)

func _on_health_changed(new_health: int, max_health: int) -> void:
	print("¡Daño recibido! Vida actual: ", new_health, "/", max_health)


func _physics_process(delta: float) -> void:
	_update_timers(delta)
	_apply_gravity(delta)
	_handle_horizontal(delta)
	_handle_jump()
	
	move_and_slide()
	_update_state()


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		var current_gravity: float = gravity * (fall_multiplier if velocity.y > 0.0 else 1.0)
		velocity.y = minf(velocity.y + current_gravity * delta, max_fall_speed)


func _update_timers(delta: float) -> void:
	if is_on_floor():
		_coyote_timer = coyote_time
	else:
		_coyote_timer = maxf(_coyote_timer - delta, 0.0)

	if Input.is_action_just_pressed("jump"):
		_buffer_timer = jump_buffer_time
	else:
		_buffer_timer = maxf(_buffer_timer - delta, 0.0)


func _handle_horizontal(delta: float) -> void:
	var dir: float = Input.get_axis("move_left", "move_right")
	
	if not is_zero_approx(dir):
		velocity.x = move_toward(velocity.x, dir * max_speed, acceleration * delta)
		facing = 1 if dir > 0.0 else -1
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)


func _handle_jump() -> void:
	if _buffer_timer > 0.0 and _coyote_timer > 0.0:
		velocity.y = jump_velocity
		_buffer_timer = 0.0
		_coyote_timer = 0.0

	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= jump_cut


func _update_state() -> void:
	var new_state: State
	
	if not is_on_floor():
		new_state = State.JUMP if velocity.y < 0.0 else State.FALL
	elif not is_zero_approx(velocity.x):
		new_state = State.RUN
	else:
		new_state = State.IDLE

	if new_state != state:
		state = new_state
		state_changed.emit(state)
