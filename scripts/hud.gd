extends CanvasLayer

@export var world: Node

func _ready():
	$TotalCoins.text = str(world.coin_count)
	$Coins.text = str(0)

func _on_coin_collected(coins):
	$Coins.text = str(coins)
