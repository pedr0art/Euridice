extends CanvasLayer
var prox_level = preload("res://scenes/inicio.tscn")
@onready var color_rect: ColorRect = $ColorRect
@onready var transition: AnimationPlayer = $transition
func _ready() -> void:
	color_rect.visible = false
	Globals.is_dialoguing = false
func _on_iniciar_pressed() -> void:
	transition.play("fade_in")
	


func _on_sair_pressed() -> void:
	get_tree().quit()


func _on_transition_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_in":
		get_tree().change_scene_to_packed(prox_level)
