extends Control

# TAMBAHKAN BARIS INI DI PALING ATAS
const CREDIT_SCENE_PATH = "res://Credit.tscn"
const GAME_SCENE_PATH = "res://World/world.tscn"

@onready var start_button = $VBoxContainer/StartButton
@onready var credit_button = $VBoxContainer/CreditButton
@onready var exit_button = $VBoxContainer/ExitButton

func _ready():
	# Hubungkan tombol (sesuaikan nama node di tree lu)
	start_button.pressed.connect(_on_start_pressed)
	credit_button.pressed.connect(_on_credit_pressed)
	exit_button.pressed.connect(_on_exit_pressed)


func _on_start_pressed():
	# Sekarang GAME_SCENE_PATH sudah dikenali
	get_tree().change_scene_to_file(GAME_SCENE_PATH)

func _on_exit_pressed():
	get_tree().quit()

func _on_credit_pressed():
	get_tree().change_scene_to_file(CREDIT_SCENE_PATH)
