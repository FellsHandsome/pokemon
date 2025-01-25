extends Area2D

# Posisi tujuan teleport
var teleport_position = Vector2(240, 112)

# Fungsi siap saat node dimasukkan ke scene
func _ready() -> void:
	# Hubungkan sinyal body_entered ke fungsi _on_body_entered
	self.connect("body_entered", Callable(self, "_on_body_entered"))

# Fungsi yang dijalankan saat ada tubuh yang masuk area
func _on_body_entered(body):
	# Debugging: Tampilkan nama body yang masuk
	print("Body entered:", body.name)

	# Pastikan body adalah player dan memiliki properti global_position
	if body.name == "player":
		print("Teleporting player to:", teleport_position)
		body.global_position = teleport_position
	else:
		print("Body is not Player.")
