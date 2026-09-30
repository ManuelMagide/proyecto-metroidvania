class_name Player
extends CharacterBody2D
## Movimiento base de un platformer lateral.
## Incluye: aceleración/fricción, salto de altura variable,
## coyote time y jump buffer.

signal state_changed(new_state: State)

enum State { IDLE, RUN, JUMP, FALL }

@export_group("Movimiento horizontal")
@export var max_speed: float = 160.0      # px/s
@export var acceleration: float = 1200.0  # px/s²
@export var friction: float = 1400.0      # px/s²

@export_group("Salto y gravedad")
@export var jump_velocity: float = -320.0     # negativo = hacia arriba
@export var gravity: float = 900.0            # px/s²
@export var fall_multiplier: float = 1.4      # cae más rápido de lo que sube
@export var max_fall_speed: float = 400.0
@export var jump_cut: float = 0.5             # recorte si sueltas el botón

@export_group("Tolerancias (game feel)")
@export var coyote_time: float = 0.1          # s para saltar tras dejar el borde
@export var jump_buffer_time: float = 0.1     # s que se recuerda un salto anticipado

var state: State = State.IDLE
var facing: int = 1  # 1 = derecha, -1 = izquierda

var _coyote_timer: float = 0.0
var _buffer_timer: float = 0.0


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_update_timers(delta)
	_handle_horizontal(delta)
	_handle_jump()
	move_and_slide()
	_update_state()


func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		return
	# Gravedad más fuerte al caer: el salto se siente menos "flotante".
	var g := gravity * (fall_multiplier if velocity.y > 0.0 else 1.0)
	velocity.y = minf(velocity.y + g * delta, max_fall_speed)


func _update_timers(delta: float) -> void:
	# Coyote time: se recarga en el suelo y decae en el aire.
	if is_on_floor():
		_coyote_timer = coyote_time
	else:
		_coyote_timer = maxf(_coyote_timer - delta, 0.0)

	# Jump buffer: recuerda que se pulsó salto justo antes de aterrizar.
	if Input.is_action_just_pressed("jump"):
		_buffer_timer = jump_buffer_time
	else:
		_buffer_timer = maxf(_buffer_timer - delta, 0.0)


func _handle_horizontal(delta: float) -> void:
	var dir := Input.get_axis("move_left", "move_right")
	if dir != 0.0:
		velocity.x = move_toward(velocity.x, dir * max_speed, acceleration * delta)
		facing = signi(int(dir))
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)


func _handle_jump() -> void:
	# Salto: hay un salto pedido (buffer) y se puede saltar (suelo o coyote).
	if _buffer_timer > 0.0 and _coyote_timer > 0.0:
		velocity.y = jump_velocity
		_buffer_timer = 0.0
		_coyote_timer = 0.0

	# Salto variable: soltar el botón mientras sube recorta la altura.
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= jump_cut


func _update_state() -> void:
	var new_state: State
	if not is_on_floor():
		new_state = State.JUMP if velocity.y < 0.0 else State.FALL
	elif absf(velocity.x) > 1.0:
		new_state = State.RUN
	else:
		new_state = State.IDLE

	if new_state != state:
		state = new_state
		state_changed.emit(state)  # luego lo usarán animaciones y sonidos
