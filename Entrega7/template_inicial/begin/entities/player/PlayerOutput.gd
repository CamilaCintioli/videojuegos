extends AudioStreamPlayer

#Audio files:
onready var jump = load("res://Audio/Sfx/Jump.ogg") 
onready var roll = load("res://Audio/Sfx/Roll.ogg") 
onready var footsteps = [load("res://Audio/Sfx/Leaves1.ogg"), load("res://Audio/Sfx/Leaves2.ogg")] 
onready var fire = load("res://Audio/Sfx/PlayerAttack.ogg")
onready var hit = load("res://Audio/Sfx/playerHurt.wav")

func fire():
	self.stream = fire
	self.play()

func hit():
	self.stream = hit
	self.play()
