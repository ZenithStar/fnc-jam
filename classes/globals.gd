class_name Global extends Object


enum Difficulty{
	EASY,
	NORMAL,
	HARD,
	LUNATIC,
}

enum Character{
	REIMU_A,
	
}

const CHARACTER_SCENES: Dictionary[Character, PackedScene] = {
	Character.REIMU_A: preload("uid://bj2crsljts8at"),
	
}

const GAMEPLAY_AREA : = Rect2(-384, -448, 768, 896)
