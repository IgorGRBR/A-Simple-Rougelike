extends KinematicBody

#constants
const GRAVITY = 9.8
const WALL_ANGLE = deg2rad(45)
const UP_VECTOR = Vector3(0, 1, 0)

#mouse sensitivity
export(float,0.1,4.0) var sensitivity_x = 2
export(float,0.1,4.0) var sensitivity_y = 1.8

#physics
export(float, 10.0, 30.0) var speed = 7.0
export(float, 0.01, 50.0) var acceleration = 50.0
export(float,10.0, 50.0) var jump_height = 25
export(float,1.0, 10.0) var mass = 8.0
export(float,0.1, 3.0, 0.1) var gravity_scl = 1.0
var stick_on_slopes = true
var snap_vector = Vector3(0, -1, 0)
var velocity = Vector3()
var vertical_velocity = Vector3()

#instances ref
onready var player_cam = $Camera
onready var ground_ray = $GroundRay
onready var collision_shape = $CollisionShape

#variables
var mouse_motion = Vector2()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	ground_ray.enabled = true
	pass

func _process(delta):
	#camera and body rotation
	rotate_y(deg2rad(20)* - mouse_motion.x * sensitivity_x * delta)
	player_cam.rotate_x(deg2rad(20) * - mouse_motion.y * sensitivity_y * delta)
	player_cam.rotation.x = clamp(player_cam.rotation.x, deg2rad(-60), deg2rad(60))
	mouse_motion = Vector2()
	

func _physics_process(delta):
	#gravity
	vertical_velocity = move_and_slide(
		vertical_velocity, 
#		snap_vector,
		UP_VECTOR,
		stick_on_slopes,
		4,
		WALL_ANGLE
	)
	vertical_velocity.x = 0
	vertical_velocity.z = 0
	print("velocity:", vertical_velocity)
	#print("vvelocity:", vertical_velocity)
	
	#character moviment
	var direction = _axis()
	
	#no walking on walls for you
	var on_floor = is_on_floor()
	if on_floor:
		
		#jump
		if Input.is_action_just_pressed("space"):
			vertical_velocity.y = jump_height
			snap_vector.y = 0
		else:
			snap_vector.y = -1
	else:
		vertical_velocity.y -= GRAVITY * gravity_scl * mass * delta
		pass
	
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	velocity.y = 0
	velocity = move_and_slide (
		velocity,
#		snap_vector,
		UP_VECTOR,
		stick_on_slopes,
		4,
		WALL_ANGLE
	)
	pass


func _input(event):
	if event is InputEventMouseMotion:
		mouse_motion = event.relative


func _axis():
	var direction = Vector3()
	
	if Input.is_key_pressed(KEY_W):
		direction -= get_global_transform().basis.z.normalized()
		
	if Input.is_key_pressed(KEY_S):
		direction += get_global_transform().basis.z.normalized()
		
	if Input.is_key_pressed(KEY_A):
		direction -= get_global_transform().basis.x.normalized()
		
	if Input.is_key_pressed(KEY_D):
		direction += get_global_transform().basis.x.normalized()
		
	return direction.normalized()
