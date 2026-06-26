extends Node

# level -> time
var best_times : Dictionary[int, float] =  { 1:INF, 2:INF, 3:INF}
var plat_times : Dictionary[int, float] =  { 1:INF, 2:INF, 3:INF}
var gold_times : Dictionary[int, float] =  { 1:INF, 2:INF, 3:INF}
var silver_times : Dictionary[int, float] =  { 1:INF, 2:INF, 3:INF}
var bronze_times : Dictionary[int, float] =  { 1:INF, 2:INF, 3:INF}

func register_times(level : int, plat : float, gold : float, silver : float, bronze : float) -> void:
	plat_times[level] = plat
	gold_times[level] = gold
	silver_times[level] = silver
	bronze_times[level] = bronze

func record_time(level : int, time : float) -> void:
	if time < best_times[level]:
		best_times[level] = time

func get_best_time(level : int) -> float:
	return best_times[level]

func get_time_color(level : int) -> Color:
	var time : float = best_times[level]
	
	if time < plat_times[level]:
		return Color("71b3e3fc")
	elif time < gold_times[level]:
		return Color("ffdf58")
	elif time < silver_times[level]:
		return Color("cfc5b5")
	elif time < bronze_times[level]:
		return Color("c47308")
	else:
		return Color.PURPLE
