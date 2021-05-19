extends KinematicBody2D

onready var fire_position = $FirePosition
onready var fire_timer = $FireTimer
onready var raycast = $FirePosition/RayCast2D
onready var remove_anim_player = $RemoveAnimPlayer
onready var sm = $CatStateMachine

var SPEED = 100 
var GRAVITY = 10 
var FLOOR = Vector2(0, -1)
var saw_player = false

onready var body_sprite = $Body
var velocity = Vector2()
var direction = 1
export (float) var FRICTION_WEIGHT:float = 0.1

export (PackedScene) var projectile_scene

var target
var projectile_container

func _ready():
	sm.initialize(self)
	fire_timer.connect("timeout", self, "fire")
	set_physics_process(false)

func initialize(container, turret_pos, projectile_container):
	container.add_child(self)
	global_position = turret_pos
	self.projectile_container = projectile_container

func _play_animation(animation_name:String):
		body_sprite.play(animation_name)

func fire():
	if target != null:
		sm.set_state(sm.STATES.SPIT)
		var proj_instance = projectile_scene.instance()
		if projectile_container == null:
			projectile_container = get_parent()
		proj_instance.initialize(projectile_container, fire_position.global_position, fire_position.global_position.direction_to(target.global_position))
		fire_timer.start()

func spit():
	body_sprite.flip_h = global_position.direction_to(target.global_position).x < 0
	raycast.set_cast_to(to_local(target.global_position))
	if raycast.is_colliding() && raycast.get_collider() == target:
		if fire_timer.is_stopped():
			fire_timer.start()
	elif !fire_timer.is_stopped():
		fire_timer.stop()

func walk():
	velocity.x = SPEED * direction     
	if direction == 1:         
		body_sprite.flip_h = false     
	else:         
		body_sprite.flip_h = true
	velocity.y += GRAVITY     
	velocity = move_and_slide(velocity, FLOOR)     
	if is_on_wall():         
		direction *= -1

func notify_hit(_amount):
	if body_sprite.animation == "dead":
		return
	#body_sprite.play("dead")
	sm.set_state(sm.STATES.DEAD)
	raycast.collision_mask = 0
	yield(body_sprite,"animation_finished")
	remove_anim_player.play("remove")

func _handle_deacceleration():
	velocity.x = lerp(velocity.x, 0, FRICTION_WEIGHT) if abs(velocity.x) > 1 else 0
	set_process(false)
	set_physics_process(false)

func _remove():
	get_parent().remove_child(self)
	queue_free()

func _on_DetectionArea_body_entered(body):
	if target == null:
		target=body
		set_physics_process(true)
		saw_player = true
		sm.set_state(sm.STATES.IDLE)
		sm.set_state(sm.STATES.SPIT)

func _on_DetectionArea_body_exited(body):
	if body == target:
		saw_player = false
		target = null
		set_physics_process(false)
		sm.set_state(sm.STATES.WALK)

func saw_player():
	return saw_player
	
func _on_Body_animation_finished():
	if body_sprite.animation == "spit":
		sm.set_state(sm.STATES.IDLE)
		
