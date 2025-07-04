extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $anim
@onready var sound_player = $AudioStreamPlayer2D
@onready var sound_area: Area2D = $Area2D
@onready var sound_shape: CircleShape2D = $Area2D/CollisionShape2D.shape
@onready var luz: PointLight2D = $PointLight2D2
@onready var camera: Camera2D = $Camera2D
@onready var gemido_1: AudioStreamPlayer2D = $gemido1
@onready var gemido_2: AudioStreamPlayer2D = $gemido2
@onready var gemido_3: AudioStreamPlayer2D = $gemido3
@onready var jumpscare: AudioStreamPlayer2D = $jumpscare
@onready var areavisao: Area2D = $areavisao
@onready var colisaovisao: CollisionShape2D = $areavisao/colisaovisao
var inimigos_vistos: Array = []

var cooldown := 2.0
var can_emit := true
var max_radius := 250.0
var max_light_scale := 1.3
var emit_speed := 20.0  # velocidade de crescimento por segundo
var emitting := false
var inimigos_alcancados: Array = []
var direcao_atual := Vector2.UP  # assume direção frontal como padrão
const SPEED := 110
func _ready():
	Globals.connect("dano_recebido", Callable(self, "_on_player_dano_recebido"))

	
func _physics_process(delta):
	if Globals.is_dialoguing:
		velocity = Vector2.ZERO
		anim.play("idle")
		return
	var direction := Vector2.ZERO

	if not emitting:
		if Input.is_action_pressed("cima"):
			direction.y = -1
			anim.play("walk_front")
		elif Input.is_action_pressed("baixo"):
			direction.y = 1
			anim.play("death")
			Globals.olhou_costa()
		elif Input.is_action_pressed("esquerda"):
			direction.x = -1
			anim.play("walk_left")
		elif Input.is_action_pressed("direita"):
			direction.x = 1
			anim.play("walk_right")
		else:
			anim.stop()
			anim.frame = 0
	else:
		# Enquanto cantando, toca animação "singing"
		if anim.animation != "singing":
			anim.play("singing")
	if direction != Vector2.ZERO:
		direcao_atual = direction.normalized()
	velocity = direction.normalized() * SPEED
	move_and_slide()

	# Crescimento do som/luz enquanto está emitindo
	if emitting:
		sound_shape.radius = min(sound_shape.radius + 80.0 * delta, max_radius)
		var new_scale = luz.scale + Vector2(1, 1) * delta
		luz.scale = Vector2(
			clamp(new_scale.x, 0.35, max_light_scale),
			clamp(new_scale.y, 0.35, max_light_scale)
		)
		detect_enemies()
func _input(event):
	if event.is_action_pressed("emitir_som") and can_emit:
		start_emitting()
	elif event.is_action_released("emitir_som") and emitting:
		stop_emitting()

func start_emitting():
	inimigos_alcancados.clear()
	emitting = true
	can_emit = false
	sound_shape.radius = 0
	luz.scale = Vector2(0.35, 0.35)
	$Area2D/CollisionShape2D.disabled = false
	sound_player.play()
	Globals.is_singing = true
	anim.play("singing")  # Começa a animação cantando

func stop_emitting():
	emitting = false
	$Area2D/CollisionShape2D.disabled = true

	if sound_player.playing:
		sound_player.stop()
	Globals.is_singing = false
	anim.stop()
	anim.play("idle")

	# Espera o cooldown antes de permitir nova emissão
	await get_tree().create_timer(cooldown).timeout
	can_emit = true

	# Após o cooldown, anima a escala da luz de volta para (1,1)
	var tween = create_tween()
	tween.tween_property(luz, "scale", Vector2(0.35, 0.35), 1.0)

func detect_enemies():
	for body in sound_area.get_overlapping_bodies():
		if body.is_in_group("inimigo") and not inimigos_alcancados.has(body):
			inimigos_alcancados.append(body)
			body.ouvir_som(global_position)
			if not jumpscare.playing:
				jumpscare.play()
func _on_player_dano_recebido(vida_restante):
	shake_camera()

	match vida_restante:
		2:
			if not gemido_1.playing:
				gemido_1.play()
		1:
			if not gemido_2.playing:
				gemido_2.play()
		0:
			if not gemido_3.playing:
				gemido_3.play()

	# Se morreu, para tudo antes de pausar
	if vida_restante <= 0:
		velocity = Vector2.ZERO
		anim.stop()
		anim.frame = 0  
func shake_camera():
	var tween = create_tween()
	var base_offset = Vector2(0, 50)

	# Shake em torno de (0, 50), com leves variações
	tween.tween_property(camera, "offset", base_offset + Vector2(10, 0), 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camera, "offset", base_offset + Vector2(-10, 0), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camera, "offset", base_offset + Vector2(0, 10), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camera, "offset", base_offset + Vector2(0, -10), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camera, "offset", base_offset, 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _on_areavisao_body_entered(body: Node2D) -> void:
	if body.is_in_group("inimigo") and not inimigos_vistos.has(body):
		inimigos_vistos.append(body)
		if not jumpscare.playing:
			jumpscare.play()
