extends CharacterBody2D

@onready var agent = $NavigationAgent2D
@onready var vision_area: Area2D = $Area2D
@onready var body_area: Area2D = $BodyArea2D
@export var speed := 90.0
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var chase: AudioStreamPlayer2D = $chase
@onready var monstro: AudioStreamPlayer2D = $monstro



var target_player: Node2D = null
var perseguindo := false
var indo_ate_som := false
var last_seen_position: Vector2
var can_attack := true
var in_attack_cooldown := false
func _ready():
	vision_area.body_entered.connect(_on_body_entered)
	vision_area.body_exited.connect(_on_body_exited)
	body_area.body_entered.connect(_on_body_collided)
func ouvir_som(posicao_alvo: Vector2):
	if target_player == null:
		last_seen_position = posicao_alvo
		agent.target_position = last_seen_position
		indo_ate_som = true
		perseguindo = true  # ativa movimento, mas não perseguição direta ainda
		if not chase.playing:
			chase.play()
func _process(delta: float) -> void:
	if not perseguindo and chase.playing:
		chase.stop()
func _on_body_entered(body):
	if body.is_in_group("player"):
		target_player = body
		perseguindo = true
		indo_ate_som = false
		if not chase.playing:
			chase.play()
		if not monstro.playing:
			monstro.play()
func _on_body_exited(body):
	if body == target_player:
		last_seen_position = target_player.global_position
		target_player = null
		agent.target_position = last_seen_position
		indo_ate_som = true
func _on_body_collided(body):
	if body.is_in_group("player") and can_attack:
		Globals.dar_dano()
		can_attack = false
		in_attack_cooldown = true
		await get_tree().create_timer(1.0).timeout
		can_attack = true
		in_attack_cooldown = false
func _physics_process(delta):
	if in_attack_cooldown:
		velocity = Vector2.ZERO
		anim.stop()
		return
	if perseguindo:
		anim.play("default")
	else:
		velocity = Vector2.ZERO
		anim.stop()
		return

	if target_player:
		agent.target_position = target_player.global_position

	elif agent.is_navigation_finished():
		if indo_ate_som:
			perseguindo = false
			indo_ate_som = false
		velocity = Vector2.ZERO
		return

	var next_pos = agent.get_next_path_position()
	var dir = next_pos - global_position

	if dir.length() > 1.0:
		velocity = dir.normalized() * speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
