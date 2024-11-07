extends Node3D

@export var coin_name: String = "coin"

@export var coin_count = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child.name.contains(coin_name):
			coin_count += 1
		else:
			for subchild in child.get_children():
				if subchild.name.contains(coin_name):
					coin_count += 1
