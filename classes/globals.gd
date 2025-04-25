class_name Global extends Object

enum Song{
	TITLE,
	STAGE_ONE,
	BOSS_ONE,
	STAGE_TWO,
	BOSS_TWO,
	STAGE_THREE,
	BOSS_THREE,
}

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

const SONGS: Dictionary[Song, AudioStream] = { # preload all the songs so that there are no hickups
	Song.TITLE: preload("uid://boab0nsa4uero"),
	Song.STAGE_ONE: preload("uid://dq4hlin7lekwp"),
	Song.BOSS_ONE: preload("uid://c410pku77ffnw"),
	Song.STAGE_THREE: preload("uid://b2jfobimj67x4"),
}

const GAMEPLAY_AREA : = Rect2(-384, -448, 768, 896)
