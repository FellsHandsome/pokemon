extends CharacterBody2D

# Monster stats
@export var speed = 10
@export var max_speed = 30
@export var FRICTION: float = 0.15

var is_alive = true
var move_direction = Vector2.ZERO
var rng = RandomNumberGenerator.new()
var target: Node2D = null  # Player as target
var is_chasing = false  # Indicates whether the monster is chasing the player

# For Area2D that detects the player (used for chasing)
@onready var area = $Area  # Ensure the node name matches

# For HitBox that triggers the battle scene
@onready var hitbox = $HitBox  # Ensure the node name matches

# Variable to track the last direction
var last_direction: String = "idle_down"  # Default to idle down

func _ready():
	# Connect signals for Area2D to start chasing
	if area:
		area.connect("body_entered", Callable(self, "_on_area_body_entered"))
		area.connect("body_exited", Callable(self, "_on_area_body_exited"))
	else:
		print("Error: 'Area2D' not found!")

	# Connect signal for hitbox to trigger battle
	if hitbox:
		hitbox.connect("body_entered", Callable(self, "_on_hitbox_body_entered"))
	else:
		print("Error: 'Hitbox' not found!")

func _physics_process(delta):
	# Apply friction to the velocity
	velocity = lerp(velocity, Vector2.ZERO, FRICTION)

	# Chase the player if in area and actively chasing
	if is_chasing and target != null and target.is_inside_tree():  # If chasing the player
		# If target exists, chase the player
		var direction_to_player = (target.global_position - global_position).normalized()
		velocity += direction_to_player * speed
		velocity = velocity.limit_length(max_speed)

		# Update last direction based on velocity
		if abs(velocity.x) > abs(velocity.y):
			if velocity.x > 0:
				last_direction = "idle_right"
			else:
				last_direction = "idle_left"
		else:
			if velocity.y > 0:
				last_direction = "idle_down"
			else:
				last_direction = "idle_up"
	else:
		# If no target or monster is not chasing, stop moving
		velocity = Vector2.ZERO

	move_and_slide()

func _process(delta):
	update_animation()

func update_animation():
	if is_chasing:
		if velocity.length() > 0:
			if abs(velocity.x) > abs(velocity.y):
				if velocity.x > 0:
					$AnimationPlayer.play("right")
					$AnimatedSprite2D.flip_h = true
				else:
					$AnimationPlayer.play("left")
					$AnimatedSprite2D.flip_h = false
			else:
				if velocity.y > 0:
					$AnimationPlayer.play("down")
				else:
					$AnimationPlayer.play("up")
		else:
			# If the monster is stationary while chasing, switch to idle animation
			if !$AnimationPlayer.is_playing() or $AnimationPlayer.current_animation != "idle":
				$AnimationPlayer.play("idle")  # Ensure you have an idle animation
	else:
		# Play the appropriate idle animation based on last direction
		if last_direction != "" and !$AnimationPlayer.is_playing():
			$AnimationPlayer.play(last_direction)
		else:
			# Stop the animation if not chasing
			if $AnimationPlayer.is_playing():
				$AnimationPlayer.stop()

# When the player enters the Area2D (start chasing)
func _on_area_body_entered(body: PhysicsBody2D):
	if body.is_in_group("player"):
		# Player enters the area, set as target and start chasing
		target = body
		is_chasing = true

# When the player exits the Area2D (stop chasing)
func _on_area_body_exited(body: PhysicsBody2D):
	if body.is_in_group("player"):
		# Player exits the area, stop chasing
		target = null
		is_chasing = false
		# Stop the animation when exiting the area
		$AnimationPlayer.stop()

# When the player enters the hitbox (trigger battle)
func _on_hitbox_body_entered(body: PhysicsBody2D):
	if body.is_in_group("player"):
		# Player enters hitbox, start battle
		SignalManager.instantiate_battle.emit()  # Trigger battle
		queue_free()  # Remove monster after battle starts
