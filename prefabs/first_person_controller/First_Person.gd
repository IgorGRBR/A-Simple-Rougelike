extends KinematicBody

#constants
const GRAVITY = 9.8
const WALL_ANGLE = deg2rad(45)
const STICK_ON_SLOPES = true
const UP_VECTOR = Vector3(0, 1, 0)

#mouse sensitivity
export(float,0.1,4.0) var sensitivity_x = 2
export(float,0.1,4.0) var sensitivity_y = 1.8

#physics
export(float,10.0, 30.0) var speed = 15.0
export(float,10.0, 50.0) var jump_height = 25
export(float,1.0, 10.0) var mass = 8.0
export(float,0.1, 3.0, 0.1) var gravity_scl = 1.0

#instances ref
onready var player_cam = $Camera
onready var ground_ray = $GroundRay
onready var collision_shape = $CollisionShape

#variables
var mouse_motion = Vector2()
var gravity_speed = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	ground_ray.enabled = true
	pass


func _physics_process(delta):
	
	#camera and body rotation
	rotate_y(deg2rad(20)* - mouse_motion.x * sensitivity_x * delta)
	player_cam.rotate_x(deg2rad(20) * - mouse_motion.y * sensitivity_y * delta)
	player_cam.rotation.x = clamp(player_cam.rotation.x, deg2rad(-47), deg2rad(47))
	mouse_motion = Vector2()
	
	#gravity
	gravity_speed -= GRAVITY * gravity_scl * mass * delta
	
	#character moviment
	var velocity = Vector3()
	velocity = _axis() * speed
	velocity.y = gravity_speed
	
	#no walking on walls for you
	var on_wall = is_on_wall()
	if on_wall:
		pass
	
	#jump
	if Input.is_action_just_pressed("space") and ground_ray.is_colliding():
		velocity.y = jump_height
	
	gravity_speed = move_and_slide(
		velocity,
		UP_VECTOR,
		STICK_ON_SLOPES,
		4,
		WALL_ANGLE
	).y
	
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
