extends CanvasLayer


func _on_Button_pressed():
	$FileDialog.popup()


func _on_FileDialog_file_selected(path):
	var file = File.new()
	file.open(path,File.READ)
	JavaScript.download_buffer(file.get_buffer(file.get_len()), "file")
	file.close()



