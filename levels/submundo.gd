extends Node

@onready var grito: AudioStreamPlayer2D = $grito

@onready var background_music: AudioStreamPlayer2D = $background
@onready var canvas_layer = $CanvasLayer
@onready var blood = canvas_layer.get_node("blood")
@onready var game_over: CanvasLayer = $Game_over
@onready var background_2: AudioStreamPlayer2D = $background_2
@onready var defeat: AudioStreamPlayer2D = $defeat

@onready var color_rect_2: ColorRect = $CanvasLayer2/ColorRect2
var resource
@onready var transition: AnimationPlayer = $transition
var prox_level = preload("res://scenes/menu.tscn")
var tween: Tween
var musica_abaixada := false  # controle do estado anterior

func _ready():
	var resource = load("res://dialogues/tutorial.dialogue")
	DialogueManager.show_dialogue_balloon(resource, "start")
	color_rect_2.visible = false
	canvas_layer.visible = false
	Globals.connect("dano_recebido", Callable(self, "_on_player_dano_recebido"))
	game_over.visible = false
	tocar_grito_loop()

	tween = create_tween()
	tween.kill()  # garante que comece limpo

func _process(_delta):
	if Globals.volta_comeco:
		await morte_e_reinicio()

	# Verifica se o estado de canto mudou
	if Globals.is_singing and not musica_abaixada:
		musica_abaixada = true
		tween.kill()
		tween = create_tween()
		tween.tween_property(background_music, "volume_db", -30.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(background_2, "volume_db", -30.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	elif not Globals.is_singing and musica_abaixada:
		musica_abaixada = false
		tween.kill()
		tween = create_tween()
		tween.tween_property(background_music, "volume_db", 0.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(background_2, "volume_db", 0.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func tocar_grito_loop() -> void:
	await get_tree().create_timer(randf_range(15.0, 40.0)).timeout
	if not grito.playing:
		grito.play()
	tocar_grito_loop()

func _on_player_dano_recebido(vida_restante):
	canvas_layer.visible = true
	var frame_index = 3 - vida_restante - 1
	frame_index = clamp(frame_index, 0, 2)
	blood.stop()
	blood.frame = frame_index
	if vida_restante <= 0:
		await morte_e_reinicio()

func morte_e_reinicio():
	if not defeat.playing:
		defeat.play()
	get_tree().paused = true
	Globals.obscurece = true
	await get_tree().create_timer(2.0).timeout
	game_over.visible = true

func _on_game_over_button_pressed():
	defeat.stop()
	get_tree().paused = false
	get_tree().reload_current_scene()
	Globals.volta_comeco = false
	Globals.obscurece = false
	Globals.player_life = 3


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Globals.is_dialoguing = true
		transition.play("fade_in")
		
		


func _on_transition_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_in":
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
