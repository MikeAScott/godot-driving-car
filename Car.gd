extends KinematicBody2D

# Parameters
var wheel_base = 70
var steering_angle = 15
var engine_power = 1000
var braking = -450
var max_speed_reverse = 250

var friction = -0.9
var drag = -0.0015
var slip_speed = 400
var low_speed_traction = 0.7
var high_speed_traction = 0.05

# Variables
var velocity = Vector2.ZERO
var steer_angle
var acceleration = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass

func _physics_process(delta):
    get_input()
    apply_friction()
    calculate_steering(delta)
    velocity += acceleration * delta
    move_and_slide(velocity)
    
func get_input():
    var turn = 0
    if Input.is_action_pressed("ui_right"):
        turn += 1
    if Input.is_action_pressed("ui_left"):
        turn -= 1
    steer_angle = turn * deg2rad(steering_angle)
    
    acceleration = Vector2.ZERO
    if Input.is_action_pressed("ui_up"):
        acceleration = transform.x * engine_power
    if Input.is_action_pressed("ui_down"):
        acceleration += transform.x * braking

    
func calculate_steering(delta):
    var rear_wheel = position - transform.x * wheel_base / 2.0
    var front_wheel = position + transform.x * wheel_base / 2.0
    rear_wheel += velocity * delta
    front_wheel += velocity.rotated(steer_angle) * delta
    var new_heading = (front_wheel - rear_wheel).normalized()
    var traction = low_speed_traction if velocity.length() < slip_speed else high_speed_traction
    var d = new_heading.dot(velocity.normalized())
    if d > 0:
        velocity = velocity.linear_interpolate(new_heading * velocity.length(), traction)
    if d < 0:
        velocity = -new_heading * min(velocity.length(), max_speed_reverse)
    rotation = new_heading.angle()
    
func apply_friction():
    if velocity.length() < 5:
        velocity = Vector2.ZERO
    var friction_force = velocity * friction
    var drag_force = velocity * velocity.length() * drag
    acceleration += drag_force + friction_force
