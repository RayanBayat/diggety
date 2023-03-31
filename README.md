### Difference with Godot 
The following godot limitations exist since the games will be exported as pcks and included as dlc-projects in the Liopep Client which is the game portal for these projects. This means that some things dont exist. 

* PRoject uses godot 3.4.4 - not latest 3.5 
* Don't add code to game_loader.gd, it will be replaced in the game client
* Projects cannot use on AutoLoad or ProjectSettings for its operations since these will be changed in the "client". 
    * Game size is 1920*1080 and window-scalling 2D and keep. 
* The game client will start and stop the projects using the start_game and back_to_client. 
* The HUD_nodes handle starting and stoping the game
    * The game_paused variable in GameLoader will change to false when the paleyr press start in the instructions 
    * The signal game_timout which is connected in the top_node.gd script will be called when the timer runs out  
    * If you have timers they need to be canaceled onb game_timeout  

* GameTime is managed by the GameLoader and uses now 120 seconds, e.g. 2 minutes. This variable can be changed for testing. In the client the clients settings will override. 
* Don't change settings - e.g. dont activate vsyn and keep the force fps 30 or at a maximum forcing to 60.
* never use this from godot ... yield(get_tree().create_timer(2), "timeout") ... this global timer can be triggerd from anywhere. Use local timers.  
* In GameLoader the function am_i_live() will return false when on development platform. Use to block/enable printing messages and to block interaktion from keys to test game with key istead of playing with your body.
* use GameLoader.add_score(value) to add points in the game. This also triggers updating of the HUD.  

* Game Fonts are provided by adding font-style functions to labes using the existing functions in GameLoader. These will use the fonts used in all games. 

In this projects I've added a few AutoLoad-scripts that will be replaced by others AutoLoaders in the client with the same name. This includes the important GameLoader which handled both loading data, storing temporary data in. a temp_data dictionary and functions to add the session_data results including game-settings for things like level and so forth. 

Games such follow the following conventions. 
* the game name and the game_folder name are important. Dont change or put data outside of the folder except for the already existing files. 
* Functionality for saving and loading savedata and loading and saving evaluation data is allready in place in a lose format in cvs file format. This will be iproved over time 


To be able to test the game you need to add Export option for HTML5 and build *outside of the repo*. Watch out so you dont accedentally add a log of large production files or other data to the repo, such as massive models and so. Keep the repo clean. 
The project contains a custom html-file for starting models which currently uses pose but we will replace that with the head tracking. 
