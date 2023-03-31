extends CanvasLayer


onready var game_timer = find_node("GameTimer")
onready var scoreLable = find_node("ScoreLabel")
onready var instructions = get_node("..").find_node("instruction_control")
onready var game_time_min_label = find_node("GameTimeMinLabel")
onready var game_time_sec_label = find_node("GameTimeSecLabel")
onready var time_out_label = find_node("TimeOutLabel")
onready var timeout_modal = find_node("TimeoutModal")

var window = null

#reset gameloader to enable restarting game using GameLoader.get_game_root().reload_current_Scen
func _ready():
	timeout_modal.visible = false	
	time_out_label.visible = false
	set_time_lables()
	set_highscore(GameLoader.highscore)
	GameLoader.connect("score_changed", self, "_on_score_changed")
	if OS.has_feature('JavaScript'):
		window = JavaScript.get_interface("window")

"""
Make sure we are getting data before activating start-button and so forth 
"""		
var s = ""
var screen_data_array = ""
func _process(_delta):
	set_time_lables()
	if GameLoader.time <= 0: 
		game_stop()
		return 
#	#TESTKOD --- TA BORT
#	if GameLoader.time == 3: 
#		GameLoader.reload_game(5)
#	#TESTKOD --- TA BORT		
	if OS.has_feature('JavaScript'): 
		s = window.results
		if GameLoader.first_time:
			if s != "" and s != null and s != "Null": 
				screen_data_array = JSON.parse(s)
				if typeof(screen_data_array.result) == TYPE_ARRAY: 
					activate_game_first_time()
	else: 
		activate_game_first_time()

func _on_score_changed(value): 
	scoreLable.text = str(value)

func activate_game_first_time(): 
	if GameLoader.first_time: 
		instructions.reactivate()
			
			
func set_time_lables(): 
	var minutes = "%02d"%[fmod(GameLoader.time, 60*60)/60]
	var seconds = "%02d"%[fmod(GameLoader.time, 60)]
	game_time_min_label.text = str(minutes)
	game_time_sec_label.text = str(seconds)

	
func reset_timer():
	$Control/end_score_control.visible = false
	game_timer.start()

func set_highscore(scr): 
	find_node("TopLabel").text = tr("TOP")+ ": " + str(scr)

func _on_GameTimer_timeout():
	GameLoader.time -= 1
	if GameLoader.time <= 0:
		game_stop()

var game_is_stoping = false
func game_stop():
	if game_is_stoping: 
		return 
	game_is_stoping = true
	$AnimationPlayer.play("run_modal")
	GameLoader.emit_signal("game_timeout")
	game_timer.stop()

	find_node("TimeOutLabel").visible = false
	find_node("end_score").text = str(GameLoader.total_score)
	
	if GameLoader.show_score:
		find_node("end_score").visible = true
	
	if GameLoader.show_highscore and GameLoader.total_score > GameLoader.highscore: 
		$Control2/CenterContainer/parts.emitting = true
		set_highscore(GameLoader.total_score)
		#2 animationplayers required becasue run_modal is not yet finnished. Should us an AnimationPlayerTree but hey ... 
		$AnimationPlayer2.play("highscore")
		
