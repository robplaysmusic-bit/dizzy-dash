class_name ResultUI extends Control

@onready var rows: Array[ResultRow] = [
	$M/V/M/V/ResultRow,
	$M/V/M/V/ResultRow2,
	$M/V/M/V/ResultRow3,
	$M/V/M/V/ResultRow4,
	$M/V/M/V/ResultRow5,
	$M/V/M/V/ResultRow6
]

func by_first(a: Array, b: Array) -> bool:
	return a[0] < b[0]

func set_score(plat: float, gold: float, silver: float, bronze: float, time: float, best: float) -> void:
	var times: Array = [
		[plat, Color("71b3e3fc"), "Platinum"],
		[gold, Color("ffdf58"), "Gold"],
		[silver, Color("cfc5b5"), "Silver"],
		[bronze, Color("c47308"), "Bronze"]
	]
	if time >= best:
		times.append([time, Color.PURPLE, "Your Time"])
		times.append([best, Color.GREEN, "Previous Best"])
	else:
		times.append([time, Color.GREEN, "NEW BEST TIME!"])
	times.sort_custom(by_first)
	for i in range(rows.size()):
		if i < times.size():
			rows[i].set_text(times[i][2], times[i][0], times[i][1])
			rows[i].visible = true
		else:
			rows[i].visible = false
