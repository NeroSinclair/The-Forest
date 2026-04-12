extends Control

# --- BAGIAN HEALTH BAR ---
var heart_red = preload("res://Player bar/Assets/LifeBarfull.png")
var heart_gray = preload("res://Player bar/Assets/LifeBarnulll.png")

@onready var hearts_container = $PlayerInfo/HeartsContainer

# --- BAGIAN PAUSE ---
# Pastikan namanya "pausemenu" (huruf kecil semua) sesuai di tab Scene
@onready var menu_pause = $pausemenu 

func _ready():
	# Pastikan menu pause sembunyi pas awal main
	if menu_pause:
		menu_pause.hide()

func _on_player_darah_berubah(darah_sekarang):
	if not hearts_container: return
	var hearts = hearts_container.get_children()
	for i in range(hearts.size()):
		if i < darah_sekarang:
			hearts[i].texture = heart_red
		else:
			hearts[i].texture = heart_gray

# --- FUNGSI BARU UNTUK TOMBOL PAUSE ---
func _on_pause_button_pressed():
	print("Game di-pause!") 
	get_tree().paused = true   # Berhentikan waktu game
	menu_pause.show()          # Munculkan menu pause yang sudah ada

func _on_button_pressed() -> void:
	pass # Replace with function body.
