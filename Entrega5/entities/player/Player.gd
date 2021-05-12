extends KinematicBody2D

onready var cannon = $Cannon
onready var animation_player = $AnimationPlayer
onready var body = $Body

const FLOOR_NORMAL := Vector2.UP  # Igual a Vector2(0, -1)
const SNAP_DIRECTION := Vector2.UP
const SNAP_LENGHT := 32.0
const SLOPE_THRESHOLD := deg2rad(46)

export (float) var ACCELERATION:float = 60.0
export (float) var H_SPEED_LIMIT:float = 600.0
export (int) var jump_speed = 500
export (float) var FRICTION_WEIGHT:float = 0.1
export (int) var gravity = 10

var projectile_container

var velocity:Vector2 = Vector2.ZERO
var snap_vector:Vector2 = SNAP_DIRECTION * SNAP_LENGHT
var is_dead = false

func initialize(projectile_container):
	self.projectile_container = projectile_container
	cannon.projectile_container = projectile_container

func get_input():
	# Cannon fire
	if Input.is_action_just_pressed("fire_cannon"):
		if projectile_container == null:
			projectile_container = get_parent()
			cannon.projectile_container = projectile_container
		cannon.fire()

	# Jump Action
	var jump = Input.is_action_just_pressed('jump')
	if jump and is_on_floor():
		velocity.y -= jump_speed

	#horizontal speed
	var h_movement_direction:int = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	if h_movement_direction != 0:
		velocity.x = clamp(velocity.x + (h_movement_direction * ACCELERATION), -H_SPEED_LIMIT, H_SPEED_LIMIT)
	else:
		velocity.x = lerp(velocity.x, 0, FRICTION_WEIGHT) if abs(velocity.x) > 1 else 0

	_set_animation(h_movement_direction, jump)

	var mouse_position:Vector2 = get_global_mouse_position()
	cannon.look_at(mouse_position)
	
func _set_animation(h_movement_direction, jump):
	if is_dead and !animation_player.is_playing():
		call_deferred("_remove")
	if h_movement_direction != 0 and is_on_floor():
		_play_animation("walk")
	if h_movement_direction != 0 and int(!body.flip_h) != h_movement_direction:
		_flip(h_movement_direction < 0)
	if jump and is_on_floor():
		_play_animation("jump")
	if !animation_player.is_playing():
		_play_animation("idle")

func _physics_process(delta):
	get_input()
	
	# Apply velocity
	var snap:Vector2
	
	velocity.y += gravity

	velocity = move_and_slide_with_snap(velocity, snap_vector, FLOOR_NORMAL, true, 4, SLOPE_THRESHOLD) # Usando move_and_slide_with_snap y con threshold de slope


func notify_hit():
	if !is_dead:
		print("I'm player and imma die")
		animation_player.stop()
		animation_player.play("die")
		is_dead = true

func _remove():
	set_physics_process(false)
	hide()
	collision_layer = 0

func _play_animation(animation_name:String):
	animation_player.play(animation_name)
	
func _flip(flip_h):
	body.flip_h = flip_h
	if flip_h:
		body.offset.x = -50
	else:
		body.offset.x = 50
