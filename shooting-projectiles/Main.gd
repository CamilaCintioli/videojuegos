extends Node

export (PackedScene) var turret_scene:PackedScene

onready var player = $Player
onready var turret = $Turret
onready var turrets = []

func _ready():
	player.initialize(self)
	turret.initialize(self, player.position)
	turrets.append(turret)
	for i in range(2):
		instantiate_turret()

func instantiate_turret():
	var new_turret = turret_scene.instance()
	add_child(new_turret)
	new_turret.initialize(self, player.position)
	turrets.append(new_turret)

func set_player_position(position):
	for turret in turrets:
		turret.set_player_position(position)
