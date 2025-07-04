extends CharacterBody2D

# Velocidade de movimento do jogador
@export var speed := 200.0

@onready var sound_player = $AudioStreamPlayer2D
@onready var sound_area = $Area2D
@onready var sound_shape : CircleShape2D = $Area2D/CollisionShape2D.shape

var cooldown := 2.0
var can_emit := true
var max_radius := 200.0
var pulse_duration := 0.5

func _physics_process(delta):
	mover(delta)

func mover(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()

	velocity = input_vector * speed
	move_and_slide()

func _input(event):
	if event.is_action_pressed("emitir_som") and can_emit:
		emitir_som()

func emitir_som():
	can_emit = false
	sound_player.play()
	animate_pulse()

	await get_tree().create_timer(0.05).timeout # Pequeno delay pra garantir física
	detect_enemies()

	await get_tree().create_timer(cooldown).timeout
	can_emit = true

func animate_pulse():
	# Garante que começa do zero
	$Area2D/CollisionShape2D.disabled = true
	sound_shape.radius = 0.0

	# Liga pra detectar
	$Area2D/CollisionShape2D.disabled = false

	var tween = create_tween()
	tween.tween_property(sound_shape, "radius", max_radius, pulse_duration)
	tween.tween_callback(Callable(self, "_on_pulse_finished"))
	

func _on_pulse_finished():
	$Area2D/CollisionShape2D.disabled = true

func detect_enemies():
	for body in sound_area.get_overlapping_bodies():
		if body.is_in_group("inimigo"):
			body.ouvir_som(global_position)
			print("Detectados:", sound_area.get_overlapping_bodies())
