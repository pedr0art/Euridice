extends CharacterBody2D

@onready var anim = $AnimationPlayer
@onready var timer = $Timer
@onready var area_direita = $area_direita
@onready var area_esquerda = $area_esquerda
@onready var light = $Light

@export var cooldown := 5.0


var firing := false

func _ready():
	anim.play("idle")
	light.enabled = false
	light.energy = 0.0  # Começa apagado

	area_direita.body_entered.connect(_on_area_entered)
	area_esquerda.body_entered.connect(_on_area_entered)

	timer.wait_time = cooldown
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout():
	if firing:
		return

	firing = true

	# Anima a luz crescendo
	light.enabled = true
	light.energy = 0.0
	var tween_up = create_tween()
	tween_up.tween_property(light, "energy", 1.2, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Começa o fogo
	anim.play("comecar_fogo")
	await anim.animation_finished

	# Acaba o fogo
	anim.play("acabando_fogo")
	await anim.animation_finished

	# Apaga a luz suavemente
	var tween_down = create_tween()
	tween_down.tween_property(light, "energy", 0.0, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tween_down.finished

	light.enabled = false
	anim.play("idle")
	firing = false
	timer.start()

func _on_area_entered(body):
	if firing and body.is_in_group("player"):
		Globals.dar_dano()
