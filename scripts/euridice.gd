extends CharacterBody2D

@onready var player: CharacterBody2D = $"../orfeu"
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

@export var follow_distance := 40.0
@export var speed := 70.0
var desaparecendo := false

func _ready():
	visible = true
	if player:
		add_collision_exception_with(player)
	global_position = player.global_position - player.direcao_atual * follow_distance

func _physics_process(delta):
	if player == null:
		return

	var behind_pos = player.global_position - player.direcao_atual * follow_distance
	var can_go_behind = is_position_walkable(behind_pos)

	var target_pos = behind_pos

	if not can_go_behind:
		# Tenta lados: direita e esquerda do player
		var right_pos = player.global_position + Vector2(follow_distance, 0)
		var left_pos = player.global_position + Vector2(-follow_distance, 0)
		var can_go_right = is_position_walkable(right_pos)
		var can_go_left = is_position_walkable(left_pos)

		if can_go_right:
			target_pos = right_pos
		elif can_go_left:
			target_pos = left_pos
		else:
			# Nenhum espaço livre atrás ou lados, fica onde está
			target_pos = global_position

	var dir = target_pos - global_position

	if dir.length() > 1.0:
		velocity = dir.normalized() * speed

		# Animação lateral (direita/esquerda)
		if abs(dir.x) > abs(dir.y):
			anim.play("side")
			anim.flip_h = dir.x < 0
		else:
			anim.play("front")
			anim.flip_h = false
	else:
		velocity = Vector2.ZERO
		# Mantém última frame (não anim.stop())
		anim.frame = 0

	move_and_slide()

func is_position_walkable(position: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	
	var params = PhysicsPointQueryParameters2D.new()
	params.position = position
	params.exclude = [self]
	params.collision_mask = collision_mask
	
	var result = space_state.intersect_point(params)
	
	return result.size() == 0
func _process(delta):
	if Globals.obscurece and not desaparecendo:
		desaparecendo = true
		var tween = create_tween()
		tween.tween_property(anim, "modulate:a", 0.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
