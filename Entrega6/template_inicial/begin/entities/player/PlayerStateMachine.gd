extends "res://entities/player/StateMachine.gd"

enum STATES {
	IDLE,
	WALK,
	JUMP,
	DEAD,
	DOUBLEJUMP,
	ROLL,
}

var animations_map:Dictionary = {
	STATES.IDLE: "idle",
	STATES.WALK: "walk",
	STATES.JUMP: "jump",
	STATES.DEAD: "dead",
	STATES.DOUBLEJUMP: "jump",
	STATES.ROLL:"roll",
}

func initialize(parent):
	.initialize(parent)
	call_deferred("set_state", STATES.IDLE)

func _state_logic(delta):
	if state != STATES.DEAD:
		parent._handle_cannon_actions()
	
	if state == STATES.IDLE || state == STATES.DEAD:
		parent._handle_deacceleration()
	else:
		parent._handle_move_input()
	parent._apply_movement()
	
	if state == STATES.ROLL:
		parent._handle_roll()

func _do_jump():
	parent.snap_vector = Vector2.ZERO
	parent.velocity.y = -parent.jump_speed
	
func _do_roll():
	parent._handle_roll()
	print("rolleando")
	
func _get_transition(delta):
	if state != STATES.DEAD && PlayerData.current_health == 0:
		parent.emit_signal("dead")
		return STATES.DEAD
	if Input.is_action_just_pressed("jump") && parent.is_on_floor() && [STATES.IDLE, STATES.WALK].has(state):
		_do_jump()
		return STATES.JUMP
	if Input.is_action_just_pressed("jump") && [STATES.JUMP].has(state):
		_do_jump()
		return STATES.DOUBLEJUMP
	if Input.is_action_just_pressed("roll") && parent.is_on_floor() && [STATES.WALK]:
		_do_roll()
		return STATES.ROLL

	match state:
		STATES.IDLE:
			if int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left")) != 0:
				return STATES.WALK
		STATES.WALK:
			if parent.move_direction == 0:
				return STATES.IDLE
		STATES.DOUBLEJUMP:
			if parent.is_on_floor():
				if parent.move_direction != 0:
					return STATES.WALK
				else:
					return STATES.IDLE
		STATES.JUMP:
			if parent.is_on_floor():
				if parent.move_direction != 0:
					return STATES.WALK
				else:
					return STATES.IDLE
		STATES.ROLL:
				if parent.stopped_rolling():
					return STATES.IDLE
	
	return null

func _enter_state(new_state, old_state):
	parent._play_animation(animations_map[new_state])

func _exit_state(old_state, new_state):
	pass
