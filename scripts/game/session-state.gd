extends Node

signal value_changed(value:int)
signal high_score_changed(value:int)
signal new_high_score_saved(value:int)

enum Ranks { F = 0, D = 1, C = 2, B = 3, A = 4, S = 5}
const RANK_NAMES = ["F", "D", "C", "B", "A", "S"]

const EFFIENCY_THRESHOLDS = [[80.0, Ranks.S], [60.0, Ranks.A], [40.0, Ranks.B], [20.0, Ranks.C], [1.0, Ranks.D]]
const DISTANCE_THRESHOLDS = [[300, Ranks.S], [240, Ranks.A], [180, Ranks.B], [120, Ranks.C], [60, Ranks.D]] 
const COMBO_THRESHOLDS = [[5.0, Ranks.S], [4.0, Ranks.A], [3.0, Ranks.B], [2.0, Ranks.C], [1.0, Ranks.D]]

# Run data to generate the score and rank
var spawned_enemy :int = 0
var dead_enemies :int = 0
var dead_enemies_points :int = 0
var time_alive_seconds :int = 0
var maximum_combo_strike :float = 1.0
var current_combo_strike :float = 1.0

var current_score :int = 0 :
	set (new_value) :
		current_score = new_value
		value_changed.emit(new_value)
		if new_value > high_score:
			high_score = new_value

var high_score :int = 0 :
	set (new_value) :
		high_score = new_value
		high_score_changed.emit(new_value)

var alive_timer :Timer
var combo_timer :Timer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameEvents.game_over.connect(_on_gameplay_end)
	GameEvents.enemy_died.connect(_on_enemy_died)
	GameEvents.enemy_spawned.connect(_on_enemy_spawned)
	GameEvents.enemy_escaped.connect(_on_enemy_escaped)
	
	combo_timer = Timer.new()
	combo_timer.timeout.connect(_on_combo_timer_timeout)
	combo_timer.wait_time = 1.5
	combo_timer.autostart = true
	add_child(combo_timer)
	
	alive_timer = Timer.new()
	alive_timer.timeout.connect(_on_alive_timer_timeout)
	alive_timer.wait_time = 1
	alive_timer.autostart = true
	add_child(alive_timer)

func _update_live_score() -> void:
	var distance_points = time_alive_seconds * 10
	current_score = int((distance_points + dead_enemies_points) * current_combo_strike)

func toggle_run_timers(is_paused: bool) -> void:
	alive_timer.paused = is_paused
	combo_timer.paused = is_paused

func reset_session_state() -> void :
	current_score = 0
	spawned_enemy = 0
	dead_enemies = 0
	dead_enemies_points = 0
	time_alive_seconds = 0
	current_combo_strike = 0.0
	maximum_combo_strike = 0.0

func _on_gameplay_end():
	if SaveManager.high_score < high_score :
		SaveManager.high_score = high_score
		SaveManager.save_data()
		ApiManager.register_high_score(high_score)
		new_high_score_saved.emit(SaveManager.high_score)
		SoundManager.play_new_highscore()

func _on_combo_timer_timeout() -> void :
	current_combo_strike = max(1.0, current_combo_strike - 0.5)
	_update_live_score()

func _on_alive_timer_timeout() -> void:
	time_alive_seconds += 1
	_update_live_score()

func _on_enemy_escaped() -> void :
	current_combo_strike = 1.0
	_update_live_score()

func _on_enemy_died(score_value: int) -> void:
	dead_enemies += 1
	dead_enemies_points += score_value
	_update_combo_strike()
	_update_live_score()

func _update_combo_strike() -> void:
	current_combo_strike += 0.1
	if current_combo_strike > maximum_combo_strike : maximum_combo_strike = current_combo_strike
	
func _on_enemy_spawned() -> void:
	spawned_enemy += 1

func get_current_score() -> int :
	var distance_points = time_alive_seconds * 10
	return (distance_points + dead_enemies_points) * maximum_combo_strike

func _get_rank_from_thresholds(value: float, thresholds: Array) -> int :
	for t in thresholds :
		if value >= t[0]:
			return t[1]
	return Ranks.F

func _calculate_kill_efficiency() -> float:
	if spawned_enemy == 0: return 0.0
	return (float(dead_enemies) / spawned_enemy) * 100.0

func calculate_score_return() -> Dictionary:
	var distance_points = time_alive_seconds * 10
	var total_score = (distance_points + dead_enemies_points) * maximum_combo_strike
	var kill_efficiency = _calculate_kill_efficiency()
	
	var eff_rank_int = _get_rank_from_thresholds(kill_efficiency, EFFIENCY_THRESHOLDS)
	var dist_rank_int = _get_rank_from_thresholds(time_alive_seconds, DISTANCE_THRESHOLDS)
	var combo_rank_int = _get_rank_from_thresholds(maximum_combo_strike, COMBO_THRESHOLDS)
	
	var final_avarage_int = round((eff_rank_int + dist_rank_int + combo_rank_int) / 3.0)
	var final_rank_string = RANK_NAMES[final_avarage_int]
	
	return {
		"total_score": round(total_score),
		"total_rank": final_rank_string,
		"kill_efficiency_value": kill_efficiency,
		"kill_efficiency_rank": RANK_NAMES[eff_rank_int],
		"distance_points_value": distance_points,
		"distance_rank": RANK_NAMES[dist_rank_int],
		"max_combo_strike_value": maximum_combo_strike,
		"max_combo_rank": RANK_NAMES[combo_rank_int]
	}
