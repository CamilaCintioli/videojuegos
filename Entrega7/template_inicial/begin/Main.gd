extends Node

onready var player = $Environment/Player
onready var GUI = $GUI
#onready var output = $BackgroundOutput 1

func _ready():
#	var bgm = load("res://Audio/Bgm/bgm.ogg") 1
#	output.stream = bgm 1
#	output.play() 1
	randomize()
	player.initialize(self)

func _unhandled_input(event):
	if event.is_action("restart"):
		_restart_level()

func _restart_level():
	get_tree().reload_current_scene()

