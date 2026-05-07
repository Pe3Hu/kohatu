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
const windrose_to_vector = {
	Bozo.Windrose.N: Vector2i(0, 1),
	Bozo.Windrose.NE: Vector2i(1, 1),
	Bozo.Windrose.E: Vector2i(1, 0),
	Bozo.Windrose.SE: Vector2i(1, -1),
	Bozo.Windrose.S: Vector2i(0, -1),
	Bozo.Windrose.SW: Vector2i(-1, -1),
	Bozo.Windrose.W: Vector2i(-1, 0),
	Bozo.Windrose.NW: Vector2i(-1, 1),
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
#endregion

const INSECT_SPRITE_SIZE = Vector2(64, 64)
const HORDE_INSECT_SIZE = Vector2i(5, 5)
