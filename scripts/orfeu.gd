extends CharacterBody2D

const SPEED := 200

func _physics_process(delta):
	var direction := Vector2.ZERO

	# Checa prioridade de direção (frente > esquerda > direita)
	if Input.is_action_pressed("cima"):
		direction.y = -1
	elif Input.is_action_pressed("esquerda"):
		direction.x = -1
	elif Input.is_action_pressed("direita"):
		direction.x = 1
	elif Input.is_action_pressed("baixo"):
		direction.y = 1

	# Aplica o movimento
	velocity = direction.normalized() * SPEED
	move_and_slide()
