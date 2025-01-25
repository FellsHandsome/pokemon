extends AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Memulai animasi "blue" secara looping
	play("blue")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
