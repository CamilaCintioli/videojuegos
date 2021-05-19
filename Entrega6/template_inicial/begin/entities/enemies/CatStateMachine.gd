extends "res://entities/player/StateMachine.gd"

enum STATES {
	IDLE,
	WALK,
	DEAD,
	SPIT,
}

var animations_map:Dictionary = {
	STATES.IDLE: "idle",
	STATES.WALK: "walk",
	STATES.DEAD: "dead",
	STATES.SPIT: "spit"
}

func initialize(parent):
	.initialize(parent)
	call_deferred("set_state", STATES.WALK)

func _state_logic(delta):
	if state == STATES.DEAD:
		parent.notify_hit(1)
	if state == STATES.IDLE:
		parent._handle_deacceleration()
	if state == STATES.WALK:
		parent.walk()
	if state == STATES.SPIT:
		parent.spit()

func _get_transition(delta):
	return state

func _enter_state(new_state, old_state):
	parent._play_animation(animations_map[new_state])

func _exit_state(old_state, new_state):
	pass
