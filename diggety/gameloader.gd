extends Node

const VALID_TYPES = [
	TYPE_BOOL,
	TYPE_INT,
	TYPE_INT_ARRAY,
	TYPE_STRING,
	TYPE_STRING_ARRAY,
	TYPE_DICTIONARY
	]

"""
GameLoader is different in the game client portal than in your project. 
Dont change, don't add functionality here. It will be replaced.   
Also, score is sett changing the total_score variable by calling add_score()
Also us get_score to check current score. 
Dont touch total_score manually 
"""

# dict for temporary data, 
# persistent between reloads of the same session.  
var temp_data = {}

#dict for persistant between play-sessions. Store think like level, previous highscores ... 
var _save_data = {}

"""
GAME_TIME - the total playtime  
time - the counter used to count down from GAME_TIME to 0 to stop the game  
"""
var GAME_TIME = 5#120
var time = 0
"""
Signal for the game timing out becasue the game time roun out. 
"""
signal game_timeout


"""
USe add_score and get_score to set and get total score. 

For a typical highscore-game like crossing/frogger the total score 
is all the scores produced added together even if the game reloads. We dont set it to zero inbetween. 
Else players stop playing before the break ends  

total_score should only be updated if GameLoader.time > 0 as should high_score
"""
var total_score = 0 setget ,total_score_get
func total_score_get():
	return total_score
signal score_changed(value)
func add_score(value): 
	if time > 0: 
		total_score += value
		emit_signal("score_changed", total_score)
	
"""
For adding fonts to labels for showing results. Often use BIG_FONT for score animations
"""
enum FONT_STYLE {BIG_FONT, MEDIUM_FONT, SMALL_FONT}

onready var game_font_120 = preload("res://LOCAL_HUD/game-fonts/HUD.tres")
onready var game_font_50 = preload("res://LOCAL_HUD/game-fonts/game_font.tres")
onready var game_font_30 = preload("res://LOCAL_HUD/game-fonts/top_score_font.tres")


onready var game_color_white = Color(0.95, 0.95, 0.95, 1)
onready var game_color_black = Color(0.05, 0.05, 0.05, 1)

onready var inst_font  = preload("res://LOCAL_HUD/design/current/fonts/header_font.tres")
func set_instruction_font(label): 
	label.set("custom_fonts/font", inst_font)

func set_label_font(label, style=FONT_STYLE.MEDIUM_FONT): 
	if style == FONT_STYLE.BIG_FONT: 
		label.set("custom_fonts/font", game_font_120)
	elif style == FONT_STYLE.MEDIUM_FONT: 
		label.set("custom_fonts/font", game_font_50)
	else: 
		label.set("custom_fonts/font", game_font_30)
	label.set("custom_colors/font_color", game_color_white)  
	label.set("custom_colors/font_outline_modulate", game_color_black) 
	
"""
Read only value of highscore. Value is updated on backend form totalscore
"""
var highscore = 0 setget , highscore_get
func highscore_get(): 
	return highscore
"""
Use to manage starting and pausing game. game_started will be true when the sensor is providing data first time. Block access to data before that.   
Later, game_paused may also be used for pausing the game if for instance, but the game needs to manage this. 
The GameLoader gives no standard fos using game_paused. We dont use get_tree().paused since it pauses all input and prcess calls. 
"""
var game_paused = false
var game_started = false

"""
Set to true on the first time, to false if the game reloads during the same session 
Usefull for reloading procedurally genreated games
"""
var first_time = true

"""
Is the game running on the production server or not. Use, e.g. to activate/deactivate 
UI-actions thar are used in testing. 
Printing is deactivated on the production server by other means and need not be protected   
"""
var im_live = false

"""
Namespace of project:
	* name of the top-level starting scene, 
	* name of the folder for all other objects, assets and so forth  
	* namespace for saving data on client   
	* change this name in godot to keep the referenses in the project  
"""
var game_namespace = "diggety"


"""
Loading HUD is managed by the GameLoader. HUD manages instruction and game_timer controls, 
and total_Score and highscore

However, the game needs to provide an res://game_namespace/instructions.tscn scen for image and labels only.  

In the game, both the game loader and the HUD/Instrctino nodes are different. Dont put any functions in the 
GameLoader or the HUDs. 
"""
var hud_nodes_scene = preload("res://LOCAL_HUD/HUD_nodes.tscn")
var hud_nodes = null

"""
#The klients can use the following location_keys. Form more, these need to be included also in the client translations 

KEY, en, sv
LOADING,Loading game...,Laddar in spel...
WARNING_START,Loading game...,Laddar in spel...
WARNING_TO_CLOSE,Standing too close! Move back.,Står för nära! Flytta bakåt.
WARNING_ON_EDGE,Moving out of the camera's view!,Du rör dig ut ur kamerans synfält!
HIGH_SCORE,High Score,Highscore
SCORE,Score,Poäng
QUIT_GAME,Quit Game,Avsluta spel
QUIT,Quit,Avsluta
LEVEL,Level,Level
RESTART,Restart,Börja om
COUNTDOWN,Will begin in,Börjar om om 
TIME_OUT,Time Out,Tiden slut
INSTR_STAND,Stand to Play, Stå för att spela
RESTARTING_IN,Restarting in,Omstart om 
INSTR_2STEAR, Steer Aircraft, Styr flygplan
INSTR_STEAR_MOVE, Move Left/Right, Gå höger/vänster
INSTR_SHOOT, Fire, Skjut
INSTR_SHOOT_MOVE, Raise both arms, Lyft båda armarna
INSTR_LEFT,Left,Vänster
INSTR_RIGHT,Right,Höger 
INSTR_UP,Forward,Framåt 
MOVE_INSTR,Lift one arm or both, Lyft en arm eller båda
INSTR_STAND,Stand to Play,Stå för att spela
SQUAT,Squat to pump,Knäböj för att pumpa
START,Start,Starta
AIM,Turn shoulders to aim,Vrid axlar för att sikta 
SHOOT,Hands above nose to shoot, Händerna över näsan för att skjuta
TOP,Top,Top
INSTR_BODY_SIDE,Stand half sideways,Stå halvt i sidled
INSTR_KNEE,Knee over hip,Knä över höft 
""" 
 

"""
# In the client portal, start game is how the game is started. 
Here, ready activates start_game 
"""
func _ready():
	load_save_data()
	start_game()
	first_time = true
	
#This function is called when the user 
func start_game(): 
	time = GAME_TIME
	total_score = 0
	TranslationServer.add_translation(load("res://LOCAL_HUD/translations.en.translation"))
	TranslationServer.add_translation(load("res://LOCAL_HUD/translations.sv.translation"))

	if hud_nodes != null: 
		hud_nodes.queue_free()
		yield(get_tree(), "idle_frame")
	
	hud_nodes = hud_nodes_scene.instance()
	add_child(hud_nodes)

var show_score = true setget set_show_score, get_show_score 
func get_show_score():
	return show_score
func set_show_score(should_show):
	show_score = should_show
	hud_nodes.find_node("ScoreLabel").visible = should_show
	#Activate togeling the right parts in the HUD 

var show_highscore = true setget set_show_highscore, get_show_highscore 
func get_show_highscore():
	return show_highscore
func set_show_highscore(should_show):
	show_highscore = should_show
	hud_nodes.find_node("TopLabel").visible = should_show
	#Activate togeling the right parts in the HUD 

"""
For games that dont use sensor, to avoid waiting for sensor start 
"""
func activate_game():
	if hud_nodes != null:
		hud_nodes.find_node("instruction_control").reactivate()
	
func show_dbg(mess):	
	hud_nodes.find_node("dbg").text = mess
	hud_nodes.find_node("dbg").visible = true
	
"""
Use instead of get_tree().reload_current_scene()
"""
func reload_game(time=0, message="RESTARTING"):
	game_paused = true
	first_time = false
	var tout = hud_nodes.find_node("TimeOutLabel")
	var anim = hud_nodes.find_node("AnimationPlayer")
	anim.play("run_modal")
	var reload_timer = Timer.new()	
	reload_timer.wait_time = 1
	reload_timer.one_shot = true
	get_game_root().add_child(reload_timer)
	tout.visible = true
	if time <= 0: 
		time = 1 #Allwasy at least one second on reloading game
	while time>0:
		tout.text = tr(message+" "+str(time) + "s")
		if GameLoader.time > 1: #Dont restart timer if game_timer is about to run out 
			reload_timer.start()
			yield(reload_timer, "timeout")
			time -= 1
		else: 
			time = 0
			GameLoader.time = 0
	
	tout.visible = false
	if GameLoader.time > 0: 
		hud_nodes.find_node("TimeoutModal").visible = false
	game_paused = false
	if GameLoader.time > 1: #Let the game end on the Game-Timer if time is less that 2 seconds 
		get_tree().reload_current_scene()
		

"""
Use instead of get_tree().get_current_scene() or get_tree().get_root(). 
Good often to find_node using GameLoader.get_game_root().find_node("unique_node_name")
"""
func get_game_root():
	return get_tree().get_current_scene()

"""
Call this function when the game has ended, either from pressing back_button or by time_out-event 
Before that
	* total_score shhould be set, 
	* GameLoader.game_data dict should be updated  
"""	
func back_to_client(): 
	if GameLoader.time > 0: 
		if im_live: #Safe way to print in development that is now active on the deplyed version 
			print("Finished early - no points")
	else: 
		if im_live:
			print(_save_data)
	GameLoader.first_time = true
	var _status = get_tree().reload_current_scene()
	start_game()

var save_data_file_name =  "user://"+game_namespace+"_save_data.csv"
#popylate THIS IN READY FROM SAVE_DATA_FILE
func save():
	var file = File.new()
	file.open(save_data_file_name, File.WRITE)
	file.store_string(to_json(_save_data))
	file.close()
	
func load_save_data():
	var file = File.new()
	if not file.file_exists(save_data_file_name):
		save()
		return
	file.open(save_data_file_name, File.READ)
	_save_data = parse_json(file.get_as_text())
	file.close()

"""
USe only these functions to get and save data. 
DAta is saved in different wasy locally and in client 
"""

func get_value(key):
	"""
	Fetches a field in our save data.
	"""
	var value = null
	if _save_data.has(key):
		value = _save_data[key]
	return value


func save_value(key, value):
	"""
	Sets a field in our save data. Returns whether it's successful or not.
	Note: The key must be a string, and the value must be a valid json type.
	"""
	# Ensure that the key is a string
	if typeof(key) == TYPE_STRING:
		# Ensure that the value is json compatible.
		if VALID_TYPES.has(typeof(value)):
			_save_data[key] = value
			return true
			save()
	return false	
	
var save_evaluation_file_name = "user://"+game_namespace+"_stats_new.csv"
func load_eval_data_file():
	var save_data = ""
	var save_file = File.new()
	if save_file.file_exists(save_evaluation_file_name):
		save_file.open(save_evaluation_file_name, File.READ)
		save_data = save_file.get_as_text()
	save_file.close()
	return save_data

func save_eval_data_file():
	var root_node = GameLoader.get_game_root()
	"""" Example of code for loading data
	var total_x = root_node.movement_tot
	var avg_width = _sum_array(root_node.shoulder_widths) / len(root_node.shoulder_widths)
	var line = user_data + "\\n" + str(total_x) + "," + str(avg_width) + "," + str(total_x/avg_width) + "," + str(root_node.registered_punches) + "," + str(GameLoader.total_score) + "," + str(root_node.bonus_points_tot) + "," + str(root_node.multiplier_breaks)
	"""
	var user_data = load_eval_data_file()
	var line = user_data + "\\n" + "Add comma, seperated, data, matching, headlines"
	var save_file = File.new()
	
	#save_file.store_string("sep=, \\n") ... add sep=, \\n for excel to automatically ppick up the cvs-file ...
	
	save_file.open(save_evaluation_file_name, File.WRITE)
	if user_data == "":
		save_file.store_string("sep=, \\n") #Required for excel, windows 
		save_file.store_string("movement_px,shoulder_width,movement_score,registered_punches,points_score,bonus_points,multiplier_breaks")
		save_file.store_string(line)
	else:
		save_file.seek_end()
		save_file.store_string(line)
	save_file.close()
	
	download_file(load_eval_data_file())

func download_file(user_string):
	if OS.has_feature('JavaScript'):
		var script_str = "function download(filename, text) {var element = document.createElement('a');element.setAttribute('href', 'data:text/csv;charset=utf-8,' + encodeURIComponent(text));element.setAttribute('download', filename);element.style.display = 'none';document.body.appendChild(element);element.click();document.body.removeChild(element);} download('stats_new.csv','%s');"%user_string
		JavaScript.eval(script_str)	
