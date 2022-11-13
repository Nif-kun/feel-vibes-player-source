extends CanvasLayer

# Important Note:
# js. = defines that its origin is of Javascript.
# args = these are required arguments by Javascript in order to get called.

# Paths
var base_dir := OS.get_user_data_dir()
var temp_dir := base_dir+"/"+"temp"
var temp_design_dir := base_dir+"/"+"temp_design"
export var config_file := "fvd_config.json" # Requires same editor config name.

# JS.Interfaces
onready var Window := JavaScript.get_interface("window")
onready var Console := JavaScript.get_interface("console")

# JS.Callbacks
var playerDesign := JavaScript.create_callback(self, "set_design")
var resetPlayerDesign := JavaScript.create_callback(self, "reset")
var startPlayerDesign := JavaScript.create_callback(self, "start")
var stopPlayerDesign := JavaScript.create_callback(self, "stop")

# CS.Objects
var zipper_script = preload("res://library/Zipper.cs")
var Zipper = zipper_script.new()

# Nodes
onready var ColorBG := $Interface/ColorBG
onready var TextureBG := $Interface/TextureBG 
onready var AtlasPlayer := $Interface/AtlasPlayer

# Common
export var _default_bg_color := Color("00ffffff")
export var _auto_start := false


# Called when the node enters the scene tree for the first time.
func _ready():
	ColorBG.color = _default_bg_color
	Window.setCallbacks(
		playerDesign, 
		resetPlayerDesign, 
		startPlayerDesign, 
		stopPlayerDesign
		)
	_create_directories()
	_clean_directories()


func _create_directories():
	var dir := Directory.new()
	if !dir.dir_exists(temp_dir):
		# warning-ignore:return_value_discarded
		dir.make_dir(temp_dir)
	if !dir.dir_exists(temp_design_dir):
		# warning-ignore:return_value_discarded
		dir.make_dir(temp_design_dir)

func _clean_directories():
	var temp_dir_files = ShortLib.get_dir_files(temp_dir)
	var temp_design_dir_files = ShortLib.get_dir_files(temp_design_dir)
	ShortLib.remove_files(temp_dir_files, temp_dir)
	ShortLib.remove_files(temp_design_dir_files, temp_design_dir)


# Triggered by calling setPlayerDesign in Javascript.
func set_design(args):
	reset(0) # placeholder param
	var file_name = args[0] # [blob] (raw file) name.
	_store_project_file(file_name) 
	_read_project_file(file_name)

func _store_project_file(file_name):
	# data_buffer assumes that js.dataBuffer.result has been given value. No existing checks.
	var data_buffer = JavaScript.eval("dataBuffer.result", true) # type: js.ArrayBuffer
	var file_path = temp_dir+"/"+file_name
	var file = File.new()
	
	# Overwrites or creates the project file in file_path (including its name and extension)
	# Afterwards, it stores the raw data of the project file before closing the file stream.
	file.open(file_path, File.WRITE)
	file.store_buffer(data_buffer)
	file.close()

func _read_project_file(file_name):
	Zipper.Unzip(temp_dir+"/"+file_name, temp_design_dir)
	var texture_images = ShortLib.get_dir_image_textures(temp_design_dir)
	var config_json = JSON.parse(ShortLib.read_text_file(temp_design_dir+"/"+config_file)).result
	_read_config_file(config_json, texture_images)

func _read_config_file(config_json, texture_images):
	# Refer to Editor for config format.
	if config_json is Dictionary:
		ColorBG.color = Color(config_json["background"]["color"])
		TextureBG.texture = texture_images[config_json["background"]["texture"]]
		AtlasPlayer.set_hframe(config_json["sprite"]["hframe"])
		AtlasPlayer.set_vframe(config_json["sprite"]["vframe"])
		AtlasPlayer.set_start_frame(config_json["sprite"]["start_frame"])
		AtlasPlayer.set_end_frame(config_json["sprite"]["end_frame"])
		AtlasPlayer.set_speed(config_json["sprite"]["speed"])
		AtlasPlayer.set_loop(config_json["sprite"]["loop"])
		AtlasPlayer.set_atlas_texture(texture_images[config_json["sprite"]["texture"]])
		if _auto_start:
			AtlasPlayer.start()


func reset(args):
	_clean_directories()
	ColorBG.color = _default_bg_color
	TextureBG.texture = null
	AtlasPlayer.set_atlas_texture(null)
	AtlasPlayer.set_hframe(1)
	AtlasPlayer.set_vframe(1)
	AtlasPlayer.set_start_frame(1)
	AtlasPlayer.set_end_frame(1)
	AtlasPlayer.set_speed(1)
	AtlasPlayer.set_loop(true)
	Console.log("[FV] Player state reset...")


func start(args):
	AtlasPlayer.start()


func stop(args):
	AtlasPlayer.stop();
