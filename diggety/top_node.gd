extends Control

var shoulder_right = Vector3(0.0, 0.0, 0.0)
var shoulder_left = Vector3(0.0, 0.0, 0.0)
var elbow_right = Vector3(0.0, 0.0, 0.0)
var elbow_left = Vector3(0.0, 0.0, 0.0)
var nose  = Vector3(0.0, 0.0, 0.0)
var wrist_right = Vector3(0.0, 0.0, 0.0)
var wrist_left = Vector3(0.0, 0.0, 0.0)

#JavaScript and data for   
var window 	
var screen_data_array = ""
var world_data_array = ""
var s = ""
var ws = "" 


func copy_to_vector(dict): 
	"""
 	assumes dict contains x,y,z 
	""" 
	return Vector3(dict.x, dict.y, dict.z)
	
func _ready():
	if OS.has_feature('JavaScript'):
		window = JavaScript.get_interface("window")
	GameLoader.connect("game_timeout", self, "_on_game_timeout")

func _on_game_timeout():
	set_process(false)

#Process for getting sensor-data and running user interaction
var should_run_eval = false
var res 

func _process(_delta):
	if not GameLoader.game_paused:
		if OS.has_feature('JavaScript') and GameLoader.game_started: 
				s = window.results
				if s != "" and s != null and s != "Null": 
					if should_run_eval: 
						ws = window.world_results
					screen_data_array = JSON.parse(s)
					#Check that we have "correct" data 
					if typeof(screen_data_array.result) == TYPE_ARRAY: 
						res = screen_data_array.result
						#Typically right is left, that is the data thats encoded for left might be whats precived as right becasue the webcam is flipped
						nose = copy_to_vector(res[0])
						shoulder_left = copy_to_vector(res[11])
						shoulder_right = copy_to_vector(res[12])
						wrist_left = copy_to_vector(res[15])
						wrist_right = copy_to_vector(res[16])

		# If we don't get any pose data, we control the player with arrow keys. For testing purposes only and never in production.
		elif  not GameLoader.game_paused and GameLoader.game_started:
			if Input.is_action_pressed("left"):
				pass
			elif Input.is_action_pressed("right"):
				pass
			elif Input.is_action_pressed("up"): 
				pass 
			elif Input.is_action_pressed("down"):
				pass#

"""
var shoulder_right = Vector3(0.0, 0.0, 0.0)
var shoulder_left = Vector3(0.0, 0.0, 0.0)
var elbow_right = Vector3(0.0, 0.0, 0.0)
var elbow_left = Vector3(0.0, 0.0, 0.0)
var hand_right  = Vector3(0.0, 0.0, 0.0)
var hand_left  = Vector3(0.0, 0.0, 0.0)

SET up vectors for all important nodes for reuse so we 
don't create new variables all the time. 
Might not bee needed.  

data_array.result[0]  == nose
data_array.result[7]  == ear_left
data_array.result[8]  == ear_right
data_array.result[9]  == mouth_left
data_array.result[10]  == mouth_right
data_array.result[11]  == left_shoulder
data_array.result[12]  == right_shoulder
data_array.result[13]  == left_elbow
data_array.result[14]  == right_elbow
data_array.result[15]  == left_wrist
data_array.result[16]  == right_wrist
data_array.result[23]  == left_hip
data_array.result[24]  == right_hip


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
INSTR_GUIDE,Follow the guide's moves,Följ guidens rörelser
PROG_NORM,Whole body,Hela kroppen
PROG_UPPER,Upper body,Överkroppen
PROG_LOWER,Lower body,Underkroppen

"""
