extends Control

var stroke_penalty = 25
var fuel_bonus = 0.1

var died: bool
var points: int
var fuel_remaining: float
var strokes: int
var final_score: int
var end_time: String

func _ready() -> void:
	pass
	
func calc_score() -> int:
	return roundi(points * (fuel_remaining * fuel_bonus) - (strokes * stroke_penalty))
	
func show_results(_died: bool, _points: int, _fuel_remaining: float, _strokes: int) -> void:
	died = _died
	points = _points
	fuel_remaining = _fuel_remaining
	strokes = _strokes
	
	end_time = Time.get_datetime_string_from_system()

	final_score = calc_score()
	
	var level_name: String = Globals.sceneController.levelPath.split("/")[-1].split(".")[0]
	
	var new_hi_score: int = Config.add_new_score(level_name, final_score, end_time)
	
	$Results/PointsCollected.text = "Points Collected: \t%d" % points
	$Results/FuelBonus.text = "Fuel Bonus: \tx%d" % (fuel_remaining * fuel_bonus)
	$Results/StrokePenalty.text = "Stroke Penalty: \t-%d" % (strokes * stroke_penalty) 
	$Results/FinalScore.text = "FINAL SCORE: \t%d Points" % (final_score)
	$HiScores/Title.text = level_name + "\nHigh Scores:"
	
	var hi_scores = Config.data.get_value("Scores", level_name, [])
	
	var hs_string: String = "\t\tScore\t\t\t\tDate"
	hs_string += "\n--------------------------------------------"
	for i in Globals.MAX_SCORES_PER_LEVEL:
		hs_string += "\n#%d.\t " % (i + 1)
		if i < hi_scores.size():
			if i == new_hi_score:
				hs_string += "[color=#11ff01]"
			hs_string += "%d" % hi_scores[i][0]
			hs_string += "\t\t\t%s" % hi_scores[i][1]
			if i == new_hi_score:
				hs_string += "[/color]"
		else:
			hs_string += "----"
	
	$HiScores/RichTextLabel.text = hs_string
	
	$AnimationPlayer.play("show")
