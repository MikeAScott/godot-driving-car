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
#var steer_angle
#var acceleration = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass

func _physics_process(delta):
    if velocity.length() < 5:
        velocity = Vector2.ZERO   
    var acceleration = get_acceleration() + get_friction() 
    var steering = get_steering()
    var heading = calculate_heading(steering, delta)
    change_heading(heading)
    
    velocity += acceleration * delta
    move_and_slide(velocity)
 
func get_acceleration():
    var acceleration = Vector2.ZERO
    if Input.is_action_pressed("ui_up"):
        acceleration = transform.x * engine_power
    if Input.is_action_pressed("ui_down"):
        acceleration = transform.x * braking
    return acceleration

func get_steering():
    var turn = 0
    if Input.is_action_pressed("ui_right"):
        turn += 1
    if Input.is_action_pressed("ui_left"):
        turn -= 1
    return turn * deg2rad(steering_angle)    
    
#func calculate_steering(delta):
#    var new_heading = calculate_heading(delta)
#    var d = new_heading.dot(velocity.normalized())
#    if d > 0:
#        velocity = apply_drift_to(new_heading)
#    if d < 0:
#        velocity = reverse_to(new_heading)
#    rotation = new_heading.angle()
    
func calculate_heading(steer_angle,delta):
    var wheel_offset = transform.x * wheel_base / 2.0
    var rear_wheel = position - wheel_offset + velocity * delta
    var front_wheel = position + wheel_offset + velocity.rotated(steer_angle) * delta
    return (front_wheel - rear_wheel).normalized()   

func change_heading(heading):
    var d = heading.dot(velocity.normalized())
    if d > 0:
        velocity = apply_drift_to(heading)
    if d < 0:
        velocity = reverse_to(heading)
    rotation = heading.angle()
    

func apply_drift_to(heading):
    var traction = low_speed_traction if velocity.length() < slip_speed else high_speed_traction
    var new_velocity = velocity.linear_interpolate(heading * velocity.length(), traction)
    return new_velocity
    
func reverse_to(heading):
    var new_velocity = -heading * min(velocity.length(), max_speed_reverse)
    return new_velocity
    
func get_friction():
    var friction_force = velocity * friction
    var drag_force = velocity * velocity.length() * drag
    if velocity.length() < 100:
        friction_force *= 3
    return drag_force + friction_force
