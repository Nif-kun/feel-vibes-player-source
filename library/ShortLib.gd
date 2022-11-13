class_name ShortLib
# Description: shortcut library for certain functions to shorten code and avoid repetitions.


static func set_script_all(objects, script):
	for x in objects:
		x.set_script(script)


static func load_texture(path:String, warn:bool=false) -> Texture:
	if File.new().file_exists(path):
		var image := Image.new()
		var image_texture := ImageTexture.new()
		var err = image.load(path)
		if err:
			if warn: push_warning("ShortLib[WRN]: image could not be loaded, file is either not an image type, corrupted, or restricted. (Substituting return value with null.)")
			return null
		image_texture.create_from_image(image)
		return image_texture
	if warn: push_warning("ShortLib[WRN]: file does not exist! (Substituting return value with null.)")
	return null


static func get_file_size(path:String, warn:bool=false) -> int:
	var file := File.new()
	if file.file_exists(path):
		# warning-ignore:return_value_discarded
		file.open(path, File.READ)
		var size : int = file.get_len()
		file.close()
		return size
	if warn: push_warning("ShortLib[WRN]: file does not exist! (Substituting return value with -1.)")
	return -1


static func get_file_name(path:String, force:bool=false, warn:bool=false) -> String:
	if File.new().file_exists(path) or force:
		var index_x = path.find_last("/")
		var index_y = path.find_last("\\")
		if index_x > -1:
			return path.substr(index_x+1)
		elif index_y > -1:
			return path.substr(index_y+1)
	elif warn: push_warning("ShortLib[WRN]: file does not exist! (Substituting return value with empty string.)")
	return ""


static func get_file_extension(path:String) -> String:
	var index = path.find_last(".")
	return path.substr(index)


static func get_file_dir(path:String, force:bool=false, warn:bool=false) -> String:
	if File.new().file_exists(path) or force:
		var index_x = path.find_last("/")
		var index_y = path.find_last("\\")
		if index_x > -1:
			return path.substr(0, index_x)
		elif index_y > -1:
			return path.substr(0, index_x)
	elif warn: push_warning("ShortLib[WRN]: file does not exist! (Substituting return value with empty string.)")
	return ""


static func get_dir_files(path:String, include_dir:bool=false, warn:bool=false) -> PoolStringArray:
	var file_names : PoolStringArray = []
	var dir = Directory.new()
	var open_err = dir.open(path)
	if open_err == OK:
		dir.list_dir_begin()
		var file = dir.get_next()
		while file != "":
			if !dir.current_is_dir():
				file_names.append(file)
			elif include_dir:
				file_names.append(file)
			file = dir.get_next()
	elif warn:
		push_warning("ShortLib[WRN]: an error occurred when trying to access the path. ERR_CODE: "+str(open_err))
	return file_names


static func write_text_file(file_path:String, text:String, overwrite:bool=true, warn:bool=false):
	var file = File.new()
	var dir = Directory.new()
	if dir.file_exists(file_path) and overwrite:
		dir.remove(file_path)
	var open_err = file.open(file_path, file.WRITE)
	if open_err == OK:
		file.store_string(text)
	elif warn: push_warning("ShortLib[WRN]: an error occurred when trying to access the path. ERR_CODE: "+str(open_err))
	file.close()


static func read_text_file(file_path:String, warn:bool=false) -> String:
	var file = File.new()
	var open_err = file.open(file_path, file.READ)
	var content := ""
	if open_err == OK:
		content = file.get_as_text()
	elif warn: push_warning("ShortLib[WRN]: an error occurred when trying to access the path. ERR_CODE: "+str(open_err))
	return content


static func get_dir_image_textures(path:String, warn:bool=false) -> Dictionary:
	var file_names : PoolStringArray = get_dir_files(path, false, warn)
	var image_textures := {}
	for file in file_names:
		var texture = load_texture(path+"/"+file, warn)
		if texture != null:
			image_textures[file] = texture
	return image_textures


# PLURAL
static func remove_files(files, path:String, warn:bool=false):
	var dir := Directory.new()
	var remove_err
	if files is PoolStringArray:
		for file in files:
			remove_err = dir.remove(path+"/"+file)
			if remove_err != OK and warn:
				push_warning("ShortLib[WRN]: an error occurred when trying to remove the file named "+file+". ERR_CODE: "+str(remove_err))

# SINGULAR
static func remove_file(file_path:String, check_name:bool=false, warn:bool=false):
	var dir := Directory.new()
	var remove_err
	if check_name:
		var file_dir := get_file_dir(file_path, true)
		var file_name := get_file_name(file_path, true).trim_suffix(get_file_extension(file_path))
		var dir_files := get_dir_files(file_dir)
		for file in dir_files:
			if file.to_lower().trim_suffix(get_file_extension(file)) == file_name:
				remove_err = dir.remove(file_dir+"/"+file)
				if remove_err != OK and warn:
					push_warning("ShortLib[WRN]: an error occurred when trying to remove the file named "+file_path+". ERR_CODE: "+str(remove_err))
	else:
		remove_err = dir.remove(file_path)
		if remove_err != OK and warn:
			push_warning("ShortLib[WRN]: an error occurred when trying to remove the file named "+file_path+". ERR_CODE: "+str(remove_err))


static func invert_float(start:float, end:float, value:float) -> float:
	return (start + end) - value


static func invert_int(start:int, end:int, value:int) -> int:
	return (start + end) - value


static func get_greater(x, y) -> float:
	if x > y:
		return x
	return y
