extends Node2D

@onready var animation_player = $AnimationPlayer
@onready var attack_damage = 0  # Base attack damage
@onready var hp_bar = $PlayerHPBar
@export var max_hp = 25
var hp = 25
var is_alive = true

# Damage bonus variables
var damage_bonus_multiplier = 1.0  # Default multiplier (no bonus)

func _ready():
	SignalManager.connect("player_hp_changed", on_player_hp_changed)
	hp = max_hp
	hp_bar.max_value = max_hp
	hp_bar.value = max_hp
	is_alive = true

func get_hp():
	return hp

func _process(delta):
	if hp <= 0 and is_alive:
		print("player is dead")
		SignalManager.emit_signal("player_dead")
		is_alive = false
	else:
		is_alive = true

func on_player_hp_changed(new_hp):
	hp -= new_hp
	hp_bar.value = hp
	print(hp)

	# Check for damage bonus
	if hp < max_hp * 0.7:  # If HP is below 70%
		damage_bonus_multiplier = 1.1  # Apply 10% damage bonus
		print("Damage bonus applied! Current multiplier: ", damage_bonus_multiplier)
	else:
		damage_bonus_multiplier = 1.0  # Reset to normal damage
		print("No damage bonus. Current multiplier: ", damage_bonus_multiplier)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "tackle":
		SignalManager.emit_signal("player_animation_finished")
	if anim_name == "thunder":
		SignalManager.emit_signal("player_animation_finished")

# Example function to deal damage to the enemy
func deal_damage_to_enemy():
	var total_damage = attack_damage * damage_bonus_multiplier  # Calculate total damage
	print("Dealing damage: ", total_damage)  # Print the current damage for debugging
	SignalManager.enemy_hp_changed.emit(total_damage)
