extends CharacterBody3D

signal coin_collected

@export_subgroup("Components")
@export var view: Node3D

@export_subgroup("Properties")
@export var movement_speed = 250
@export var jump_strength = 7
@export var friction = 10
@export var static_friction_multiplier = 10.1
@export var air_movement = false

var movement_velocity: Vector3
var rotation_direction: float
var gravity = 0

var previously_floored = false

var jump_single = true
var jump_double = true

var apply_movement = false
var jump_movement = false

var previous_input = Vector3(0,0,0)

@export var coins = 0		

@onready var particles_trail = $ParticlesTrail
#@onready var sound_footsteps = $SoundFootsteps
@onready var model = $CollisionShape3D/MeshInstance3D
@onready var animation = $AnimationPlayer

# Functions
func _physics_process(delta):
	
	# Handle functions
	handle_controls(delta)
	handle_gravity(delta)
	
	handle_effects()
	
	# Movement
	var applied_velocity: Vector3
	if jump_movement:
			jump_movement = false
			applied_velocity = movement_velocity
	else:
		if apply_movement or air_movement:
			apply_movement = false
			
			var dynamic_friction = friction
			if movement_velocity.is_zero_approx():
				dynamic_friction *= static_friction_multiplier
			
			applied_velocity = velocity.lerp(movement_velocity, delta * dynamic_friction)
		else:
			applied_velocity = velocity	
	applied_velocity.y = -gravity
	
	velocity = applied_velocity
	move_and_slide()
	
	# Rotation
	
	if Vector2(velocity.z, velocity.x).length() > 0:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()
		
	rotation.y = lerp_angle(rotation.y, rotation_direction, delta * 10)
	
	# Falling/respawning
	if position.y < -10:
		get_tree().reload_current_scene()
	
	# Animation for scale (jumping and landing)
	
	#model.scale = model.scale.lerp(Vector3(1, 1, 1), delta * 10)
	
	# Animation when landing
	
	if is_on_floor() and gravity > 2 and !previously_floored:
		#model.scale = Vector3(1.25, 0.75, 1.25)
		Audio.play("res://sounds/land.ogg")
	
	previously_floored = is_on_floor()

# Handle animation(s)
func handle_effects():
	
	particles_trail.emitting = false
	#sound_footsteps.stream_paused = true
	
	if is_on_floor():
		if abs(velocity.x) > 1 or abs(velocity.z) > 1:
			#animation.play("walk", 0.5)
			particles_trail.emitting = true
			#sound_footsteps.stream_paused = false
			pass
		else:
			pass
			#animation.play("idle", 0.5)
	else:
		#animation.play("jump", 0.5)
		pass

# Handle movement input
func handle_controls(delta):
	
	# Movement
	
	var input := Vector3.ZERO
	
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_back")

	input = input.rotated(Vector3.UP, view.rotation.y).normalized()
	
	if is_on_floor():
		apply_movement = true
	
	movement_velocity = input * movement_speed * delta
	
	# Jumping
	if Input.is_action_just_pressed("jump"):
		
		if jump_single or jump_double:
			Audio.play("res://sounds/jump.ogg")
			animation.play("jump")
			gravity = -jump_strength
			jump_movement = true
		
		if jump_double:
			jump_double = false
			#model.scale = Vector3(0.5, 1.5, 0.5)
		if(jump_single): 
			#model.scale = Vector3(0.5, 1.5, 0.5)
			jump_double = true;
			jump_single = false


# Handle gravity
func handle_gravity(delta):
	gravity += 25 * delta
	 
	if gravity > 0 and is_on_floor():
		jump_single = true
		gravity = 0

# Collecting coins
func collect_coin():
	
	coins += 1
	
	coin_collected.emit(coins)
