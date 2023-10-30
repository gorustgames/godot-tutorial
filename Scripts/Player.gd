
extends CharacterBody2D

# Player movement speed
@export var speed = 50
@onready var animation_sprite = $AnimatedSprite2D

var new_direction = Vector2(0,1) #only move one spaces
var animation

var is_attacking = false


func _physics_process(delta):
	# Get player input (left, right, up/down)
	var direction: Vector2
	direction.x = Input.get_action_strength("ui_right") -Input.get_action_strength("ui_left")

	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	# If input is digital, normalize it for diagonal movement
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()
		
	# Sprinting          
	if Input.is_action_pressed("ui_sprint"):
		speed = 100
	elif Input.is_action_just_released("ui_sprint"):
		speed = 50  		

	# Apply movement
	var movement = speed * direction * delta
	
	if is_attacking == false:
		# Moves our player around, whilst enforcing collisions so that they come to a stop when colliding with another object.
		move_and_collide(movement)
		player_animations(direction)
		
	# If no input is pressed, idle
	if !Input.is_anything_pressed():
		if is_attacking == false:
			animation  = "idle_" + returned_direction(new_direction)		

func player_animations(direction : Vector2):
	#Vector2.ZERO is the shorthand for writing Vector2(0, 0).
	if direction != Vector2.ZERO:
		#update our direction with the new_direction
		new_direction = direction
		#play walk animation, because we are moving
		animation = "walk_" + returned_direction(new_direction)
		animation_sprite.play(animation)
	else:
		#play idle animation, because we are still
		animation  = "idle_" + returned_direction(new_direction)
		animation_sprite.play(animation)

func returned_direction(direction : Vector2):
	#it normalizes the direction vector 
	var normalized_direction  = direction.normalized()
	var default_return = "side"

	if normalized_direction.y > 0:
		return "down"
	elif normalized_direction.y < 0:
		return "up"
	elif normalized_direction.x > 0:
		#(right)
		$AnimatedSprite2D.flip_h = false
		return "side"
	elif normalized_direction.x < 0:
		#flip the animation for reusability (left)
		$AnimatedSprite2D.flip_h = true
		return "side"

	#default value is empty
	return default_return

func _input(event):
	#input event for our attacking, i.e. our shooting
	if event.is_action_pressed("ui_attack"):
		#attacking/shooting anim
		is_attacking = true
		var animation  = "attack_" + returned_direction(new_direction)
		animation_sprite.play(animation)


func _on_animated_sprite_2d_animation_finished():
	is_attacking = false
