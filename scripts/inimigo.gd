extends CharacterBody2D

@export var speed := 100.0
@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var vision_area: Area2D = $Area2D

var target_player: Node2D = null
var last_seen_position: Vector2
var perseguindo := false

func _ready():
	vision_area.body_entered.connect(_on_body_entered)
	vision_area.body_exited.connect(_on_body_exited)

func ouvir_som(posicao_alvo: Vector2):
	if target_player == null:
		last_seen_position = posicao_alvo
		agent.target_position = last_seen_position
		perseguindo = true

func _on_body_entered(body):
	if body.is_in_group("player"):
		target_player = body
		perseguindo = true

func _on_body_exited(body):
	if body == target_player:
		last_seen_position = target_player.global_position
		target_player = null
		agent.target_position = last_seen_position

func _physics_process(delta):
	if not perseguindo:
		velocity = Vector2.ZERO
		return

	# Atualiza o target em tempo real se vê o player
	if target_player:
		agent.target_position = target_player.global_position

	if agent.is_navigation_finished():
		velocity = Vector2.ZERO
		if target_player == null:
			perseguindo = false
		return

	# 🚩 Aqui usamos get_next_path_position() manualmente
	var next_pos = agent.get_next_path_position()
	var direcao = next_pos - global_position

	if direcao.length() > 1.0:
		velocity = direcao.normalized() * speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
