extends CanvasLayer

var image_1 = load("res://assets/scenes/orfeu.png")
var image_2 = load("res://assets/scenes/hades full.png")
var image_3 = load("res://assets/scenes/hades perfil.png")
var image_4 = load("res://assets/scenes/persefone.png")
@onready var color_rect: ColorRect = $ColorRect
@onready var transition: AnimationPlayer = $transition

@onready var sprite_2d: Sprite2D = $Sprite2D
var current_texture: Texture = null
var avanco = false 
var prox_level = preload("res://levels/mapa.tscn")
func _ready() -> void:

	var resource = load("res://dialogues/Inicio.dialogue")
	DialogueManager.show_dialogue_balloon(resource, "start")

func _process(delta: float) -> void:
	var new_texture: Texture = null
	var new_scale: Vector2 = Vector2.ONE  # escala padrão

	if Globals.orfeu:
		new_texture = image_1
	elif Globals.hades_full:
		new_texture = image_2
	elif Globals.hades_perfil:
		new_texture = image_3
	elif Globals.persefone:
		new_texture = image_4
		new_scale = Vector2(0.5, 0.5)  # metade do tamanho

	if new_texture != null and sprite_2d.texture != new_texture:
		sprite_2d.texture = new_texture
		sprite_2d.scale = new_scale
	if avanco:
		transition.play("fade_out")
		


func _on_transition_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_out":
		get_tree().change_scene_to_packed(prox_level)
