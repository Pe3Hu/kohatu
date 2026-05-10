extends Node


#region capsule
const HULL_CAPSULE_SIZE = Vector2i(3, 3)
const CAPSULE_SPRITE_SIZE = Vector2(128, 128)

const capsule_to_color = {
	Bozo.Capsule.NONE: Color.WHITE,
	Bozo.Capsule.MIDDLE: Color.BLUE,
	Bozo.Capsule.LEFT: Color.ORANGE,
	Bozo.Capsule.RIGHT: Color.GREEN,
}
#endregion

#region windrose
#const windrose_to_direction = {
	#Bozo.Windrose.N: Vector2i(0, 1),
	#Bozo.Windrose.NE: Vector2i(1, 1),
	#Bozo.Windrose.E: Vector2i(1, 0),
	#Bozo.Windrose.SE: Vector2i(1, -1),
	#Bozo.Windrose.S: Vector2i(0, -1),
	#Bozo.Windrose.SW: Vector2i(-1, -1),
	#Bozo.Windrose.W: Vector2i(-1, 0),
	#Bozo.Windrose.NW: Vector2i(-1, 1),
#}
#
#const direction_to_windrose = {
	#Vector2i(0, 1): Bozo.Windrose.N,
	#Vector2i(1, 1): Bozo.Windrose.NE,
	#Vector2i(1, 0): Bozo.Windrose.E,
	#Vector2i(1, -1): Bozo.Windrose.SE,
	#Vector2i(0, -1): Bozo.Windrose.S,
	#Vector2i(-1, -1): Bozo.Windrose.SW,
	#Vector2i(-1, 0): Bozo.Windrose.W,
	#Vector2i(-1, 1): Bozo.Windrose.NW,
#}

const windrose_to_direction = {
	Bozo.Windrose.N: Vector2i(0, -1),
	Bozo.Windrose.NE: Vector2i(1, -1),
	Bozo.Windrose.E: Vector2i(1, 0),
	Bozo.Windrose.SE: Vector2i(1, 1),
	Bozo.Windrose.S: Vector2i(0, 1),
	Bozo.Windrose.SW: Vector2i(-1, 1),
	Bozo.Windrose.W: Vector2i(-1, 0),
	Bozo.Windrose.NW: Vector2i(-1, -1),
}

const direction_to_windrose = {
	Vector2i(0, -1): Bozo.Windrose.N,
	Vector2i(1, -1): Bozo.Windrose.NE,
	Vector2i(1, 0): Bozo.Windrose.E,
	Vector2i(1, 1): Bozo.Windrose.SE,
	Vector2i(0, 1): Bozo.Windrose.S,
	Vector2i(-1, 1): Bozo.Windrose.SW,
	Vector2i(-1, 0): Bozo.Windrose.W,
	Vector2i(-1, -1): Bozo.Windrose.NW,
}

const windrose_to_mirror = {
	Bozo.Windrose.N: Bozo.Windrose.S,
	Bozo.Windrose.NE: Bozo.Windrose.SW,
	Bozo.Windrose.E: Bozo.Windrose.W,
	Bozo.Windrose.SE: Bozo.Windrose.NW,
	Bozo.Windrose.S: Bozo.Windrose.N,
	Bozo.Windrose.SW: Bozo.Windrose.NE,
	Bozo.Windrose.W: Bozo.Windrose.E,
	Bozo.Windrose.NW: Bozo.Windrose.SE
}

const windrose_to_palette = {
	Bozo.Windrose.N: Vector2i(0, 0),
	Bozo.Windrose.NE: Vector2i(0, 1),
	Bozo.Windrose.E: Vector2i(1, 0),
	Bozo.Windrose.SE: Vector2i(1, 1),
	Bozo.Windrose.S: Vector2i(2, 0),
	Bozo.Windrose.SW: Vector2i(2, 1),
	Bozo.Windrose.W: Vector2i(3, 0),
	Bozo.Windrose.NW: Vector2i(3, 1)
}

const orthogonal_windroses = [
	Bozo.Windrose.N,
	Bozo.Windrose.E,
	Bozo.Windrose.S,
	Bozo.Windrose.W
]

const diagonal_windroses = [
	Bozo.Windrose.NE,
	Bozo.Windrose.SE,
	Bozo.Windrose.SW,
	Bozo.Windrose.NW
]

const windrose_to_neighbour = {
	Bozo.Windrose.N: [Vector2i(-1, 0), Vector2i(1, 0)],
	#Bozo.Windrose.NE: [Vector2i(1, 1)],
	Bozo.Windrose.E: [Vector2i(0, -1), Vector2i(0, 1)],
	#Bozo.Windrose.SE: [Vector2i(1, -1)],
	Bozo.Windrose.S: [Vector2i(-1, 0), Vector2i(1, 0)],
	#Bozo.Windrose.SW: [Vector2i(-1, -1)],
	Bozo.Windrose.W: [Vector2i(0, -1), Vector2i(0, 1)],
	#Bozo.Windrose.NW: [Vector2i(-1, 1)],
}
#endregion

const INSECT_SPRITE_SIZE = Vector2(64, 64)
#const HORDE_INSECT_SIZE = Vector2i(6, 6)
const HORDE_MAX_RING = 6
const STARTER_HORDE_INSECT_COUNT = 23
const EMPTY_INSECT_COORD = Vector2i(3, 3)
