extends Node

var player_life = 3
signal dano_recebido
var volta_comeco = false
var obscurece = false
var is_singing = false
var orfeu = true
var hades_full = false
var hades_perfil = false
var persefone = false
var is_dialoguing = false
func dar_dano():
	if player_life > 0:
		player_life -= 1
		emit_signal("dano_recebido", player_life)
func olhou_costa():
	volta_comeco = true
	
