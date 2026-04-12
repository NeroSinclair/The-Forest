extends Control

# Pastikan path ini sesuai dengan letak scene world/gameplay kamu
const MAIN_MENU_PATH = "res://Main menu/main_menu.tscn"

@onready var resume_button = $VBoxContainer/StartButton
@onready var restart_button = $VBoxContainer/Restart # Sesuaikan nama nodenya
@onready var exit_button = $VBoxContainer/ExitButton

func _ready():
	# Pastikan node ini tetap jalan saat game pause
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Hubungkan signal jika belum lewat editor (opsional kalau sudah connect via editor)
	# start_button.pressed.connect(_on_resume_button_pressed)
	# exit_button.pressed.connect(_on_exit_button_pressed)

# Fungsi untuk RESUME (Balik ke game)
func _on_resume_button_pressed() -> void:
	get_tree().paused = false # Jalankan game lagi
	hide() # Sembunyikan menu pause ini

# Fungsi untuk RESTART (Ngulang level)
func _on_restart_button_pressed() -> void:
	get_tree().paused = false # Pastikan unpause dulu sebelum reload
	get_tree().reload_current_scene() # Ngulang scene yang sedang jalan

# Fungsi untuk EXIT (Keluar ke Desktop)
func _on_exit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
