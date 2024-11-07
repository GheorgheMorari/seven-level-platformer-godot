extends Node3D

@export var player: CharacterBody3D
@export var world: Node3D
@export var new_scene: PackedScene



func _on_body_entered(body):
	if (body == player) and (new_scene != null):
		if player.coins == world.coin_count:
			get_tree().change_scene_to_packed(new_scene) 
		

