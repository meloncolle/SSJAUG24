extends Control

var died: bool
var points: int
var fuel_remaining: float
var strokes: int
var final_score: int
var end_time: float

func _ready() -> void:
	pass
	
func calc_score() -> int:
	return roundi(points * (fuel_remaining * .1) - (strokes * 25))
	
func show_results(_died: bool, _points: int, _fuel_remaining: float, _strokes: int) -> void:
	died = _died
	points = _points
	fuel_remaining = _fuel_remaining
	strokes = _strokes
	
	end_time = Time.get_unix_time_from_system()

	final_score = calc_score()
	
	var level_name: String = Globals.sceneController.levelPath.split("/")[-1].split(".")[0]
	
	var new_hi_score: bool = Config.add_new_score(level_name, final_score, end_time)
		
	print(Config.data.get_value("Scores", level_name, []))
	
