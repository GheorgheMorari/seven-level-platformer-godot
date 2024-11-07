extends Node3D

@export_group("Properties")
@export var target: Node


@export_group("Zoom")
@export var zoom_minimum = 16
@export var zoom_maximum = 4
@export var zoom_speed = 10

@export_group("Rotation")
@export var rotation_speed = 120


@export_group("Drunkness")
@export var intensity = 0.0
@export var coin_intensity = 0.0

@export var horizontal_bobbing_speed = 0.1
@export var horizontal_bobbing_amplitude = 0.1

@export var vertical_bobbing_speed = 0.1
@export var vertical_bobbing_amplitude = 0.1

var vertical_bobbing_seed = randi()
var horizontal_bobbing_seed = randi()

var camera_rotation:Vector3
var zoom = 10.0

const min_camera_x = -89
const max_camera_x = 89
var mouse_sensitivity = 0.3

@onready var camera = $Camera

func _ready():

	camera_rotation = rotation_degrees # Initial rotation
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pass

func _physics_process(delta):
	var real_intensity = intensity + coin_intensity * target.coins
	# Set position and rotation to targets
	camera_rotation.y -= sin((horizontal_bobbing_seed + Time.get_unix_time_from_system()) * horizontal_bobbing_speed) * horizontal_bobbing_amplitude * real_intensity * zoom
	camera_rotation.x += sin((vertical_bobbing_seed + Time.get_unix_time_from_system()) * vertical_bobbing_speed) * vertical_bobbing_amplitude * real_intensity * zoom
	camera_rotation.x = clamp(camera_rotation.x, min_camera_x, max_camera_x)
	
	self.position = self.position.lerp(target.position, delta * 4)
	rotation_degrees = rotation_degrees.lerp(camera_rotation, delta * 6)
	
	camera.position = camera.position.lerp(Vector3(0, 0, zoom), 8 * delta)
	
	handle_input(delta)

func _input(event):
	if event is InputEventMouseMotion:
		camera_rotation.y += -event.relative.x * mouse_sensitivity
		camera_rotation.x += -event.relative.y * mouse_sensitivity

# Handle input

func handle_input(delta):
	
	# Rotation
	
	var input := Vector3.ZERO
	
	#input.y = Input.get_axis("camera_left", "camera_right")
	#input.x = Input.get_axis("camera_up", "camera_down")
	
	camera_rotation += input.limit_length(1.0) * rotation_speed * delta
	#camera_rotation.x = clamp(camera_rotation.x, -80, -10)
	
	# Zooming
	
	zoom += Input.get_axis("zoom_in", "zoom_out") * zoom_speed * delta
	zoom = clamp(zoom, zoom_maximum, zoom_minimum)

