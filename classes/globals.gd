class_name Global extends Object


enum Difficulty{
	EASY,
	NORMAL,
	HARD,
	LUNATIC,
}

enum Character{
	FLANDRE_A,
	
}

enum Stage{
	STAGE_TEST,
	STAGE_ONE,
	
}

const CHARACTER_SCENES: Dictionary[Character, PackedScene] = {
	Character.FLANDRE_A: preload("uid://bj2crsljts8at"),
	
}

const STAGE_SCENES: Dictionary[Stage, PackedScene] = {
	Stage.STAGE_TEST: preload("uid://ji0yg461mfxp"),
	Stage.STAGE_ONE: preload("uid://01bkdsupqkvr"),
	
}

const GAMEPLAY_AREA : = Rect2(-384, -448, 768, 896)
