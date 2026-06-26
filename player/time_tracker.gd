extends Node

# level -> time (sec_
var best_times : Dictionary[int, float] =  { 1:INF, 2:INF, 3:INF}

func record_time(level : int, time : float):
	if time < best_times[level]:
		best_times[level] = time

func get_best_time(level : int):
	return best_times[level]
