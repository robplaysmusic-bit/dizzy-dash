class_name ResultUI extends Control

class Score:
	var description: String
	var color: Color
	var time: float

	func _init(desc: String, clr: Color, t: float) -> void:
		self.description = desc
		self.color = clr
		self.time = t

@onready var rows: Array[ResultRow] = [
	$M/V/M/V/ResultRow,
	$M/V/M/V/ResultRow2,
	$M/V/M/V/ResultRow3,
	$M/V/M/V/ResultRow4,
	$M/V/M/V/ResultRow5,
	$M/V/M/V/ResultRow6
]

func by_time(a: Score, b: Score) -> bool:
	return a.time > b.time

func set_score(plat: float, gold: float, silver: float, bronze: float, time: float, best: float) -> void:
	var times: Array[Score] = [
		Score.new("Platinum", Color("71b3e3fc"), plat),
		Score.new("Gold", Color("ffdf58"), gold),
		Score.new("Silver", Color("cfc5b5"), silver),
		Score.new("Bronze", Color("c47308"), bronze),
	]
	if time > best:
		times.append(Score.new("Your Time", Color.PURPLE, time))
		times.append(Score.new("Personal Best", Color.GREEN, best))
	else:
		times.append(Score.new("NEW PERSONAL BEST!", Color.GREEN, time))
	times.sort_custom(by_time)
	for i in range(rows.size()):
		if i < times.size():
			rows[i].set_text(times[i].description, times[i].time, times[i].color)
			rows[i].visible = true
		else:
			rows[i].visible = false
