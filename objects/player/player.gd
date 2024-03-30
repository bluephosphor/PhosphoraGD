extends CharacterBody3D

# basic state values
var max_speed = 5
var accel = 10
var frict = 20
var jump_velocity = 7
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# tracking spin state
const SPIN_AERIAL_JUMP = 150
var max_spin_duration = 1
var spin_time = 0.0

# tracking the sprite rotation
const SPR_ROT_SPEED = 0.15
var target_yrot = 0.0
var current_yrot = 0.0

# tracking the state
var current_state = state_normal
var state_switch = true

func _physics_process(delta):
	current_state.call(delta)
	move_and_slide()
	
	# apply sprite rotation state
	current_yrot = lerp(current_yrot,target_yrot,SPR_ROT_SPEED)
	$AnimatedSprite3D.rotation = Vector3(0,current_yrot,0)
	
	# make camera controller match position of self
	$Camera_Controller.position = lerp($Camera_Controller.position, position, 0.15)

func move_commit(delta, input_dir):
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = lerp(velocity.x, direction.x * max_speed, accel * delta)
		velocity.z = lerp(velocity.z, direction.z * max_speed, accel * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, frict * delta)
		velocity.z = lerp(velocity.z, 0.0, frict * delta)

func state_normal(delta):
	if state_switch:
		state_switch = false
		$AnimatedSprite3D.animation = "walk"
		$SpinParticles.emitting = false
		max_speed = 5
		accel = 20
		frict = 20
		jump_velocity = 7
		gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# handle spin
	if Input.is_action_just_pressed("world_action"):
		set_state(state_spin)
	# flip sprite when moving left or right
	if Input.is_action_just_pressed("ui_left"):
		target_yrot = deg_to_rad(180)
	elif Input.is_action_just_pressed("ui_right"):
		target_yrot = 0.0
	
	# Get the input direction 
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# animation
	if is_on_floor():
		if input_dir:
			$AnimatedSprite3D.play()
		else:
			$AnimatedSprite3D.set_frame_and_progress(0,0)
			$AnimatedSprite3D.pause()
	else:
		if velocity.y > 0:
			$AnimatedSprite3D.set_frame_and_progress(3,0)
		else:
			$AnimatedSprite3D.set_frame_and_progress(1,0)
		$AnimatedSprite3D.pause()

	move_commit(delta, input_dir)

func state_spin(delta):
	if state_switch:
		state_switch = false
		$AnimatedSprite3D.animation = "spin"
		$AnimatedSprite3D.play()
		$SpinParticles.emitting = true

		if not is_on_floor():
			velocity.y += SPIN_AERIAL_JUMP * delta
		
		max_speed = 10
		accel = 5
		frict = 3
		jump_velocity = 7
		gravity = 10
		spin_time = 0.0
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# handle spin lifespan
	if spin_time < max_spin_duration:
		spin_time += delta
	else:
		$SpinParticles.emitting = false
		set_state(state_normal)
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	move_commit(delta, input_dir)
	
func state_swim_normal(delta):
	if state_switch:
		state_switch = false
		$AnimatedSprite3D.animation = "walk"
		velocity.y = 0
		max_speed = 2
		accel = 5
		frict = 5
		jump_velocity = 2
		gravity = 5
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle vertical swim.
	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = jump_velocity
	
	# Get the input direction 
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# flip sprite when moving left or right
	if Input.is_action_just_pressed("ui_left"):
		target_yrot = deg_to_rad(180)
	elif Input.is_action_just_pressed("ui_right"):
		target_yrot = 0.0
	
	# animation
	if is_on_floor():
		if input_dir:
			$AnimatedSprite3D.play()
		else:
			$AnimatedSprite3D.set_frame_and_progress(0,0)
			$AnimatedSprite3D.pause()
	else:
		if velocity.y > 0:
			$AnimatedSprite3D.set_frame_and_progress(3,0)
		else:
			$AnimatedSprite3D.set_frame_and_progress(1,0)
		$AnimatedSprite3D.pause()

	move_commit(delta, input_dir)

func set_state(state):
	state_switch = true
	current_state = state
