extends Token
class_name MiningToken


@export var ore_gain: int = 2


func execute():
	super.execute()
	var gain = max(0, ore_gain)

	GameState.add_ore(gain)
