extends Node2D

@onready var zombie_scene = preload("res://World/Zombie.tscn")

func _ready():
	# 1. Spawn 10 zombie saat awal game
	for i in range(10):
		spawn_zombie_random()
	
	# 2. Koneksi Signal Otomatis (Sebagai pengaman jika belum konek di Editor)
	# Kita pastikan Aris dan UIGame bisa ditemukan
	if has_node("Aris") and has_node("CanvasLayer/UIGame"):
		var aris = $Aris
		var ui = $CanvasLayer/UIGame
		
		# Jika signal belum tersambung, kita sambungkan sekarang
		if not aris.darah_berubah.is_connected(ui._on_player_darah_berubah):
			aris.darah_berubah.connect(ui._on_player_darah_berubah)
			# Panggil sekali di awal agar UI update jumlah hati saat start
			ui._on_player_darah_berubah(aris.darah)

func spawn_zombie_random():
	var spawn_pos = Vector2.ZERO
	var pos_valid = false
	var percobaan = 0
	var maksimal_percobaan = 30 

	while not pos_valid and percobaan < maksimal_percobaan:
		percobaan += 1
		# Menentukan posisi random (sesuaikan dengan lebar map kamu)
		var x_pos = randf_range(100, 1100)
		var y_pos = randf_range(100, 600)
		spawn_pos = Vector2(x_pos, y_pos)
		
		# Cek apakah area tersebut kosong (tidak ada pohon/tembok)
		if not cek_area_bertabrakan(spawn_pos):
			pos_valid = true

	if pos_valid:
		var zombie_baru = zombie_scene.instantiate()
		zombie_baru.global_position = spawn_pos
		add_child(zombie_baru)

# Fungsi untuk mengecek tabrakan fisik sebelum spawn
func cek_area_bertabrakan(pos: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	
	var shape_query = PhysicsShapeQueryParameters2D.new()
	var lingkaran = CircleShape2D.new()
	lingkaran.radius = 15.0 # Radius seukuran badan zombie
	
	shape_query.shape = lingkaran
	shape_query.transform = Transform2D(0, pos)
	
	# Collision Mask 1 biasanya untuk Environment (Pohon, Pagar, dll)
	shape_query.collision_mask = 1 
	
	var result = space_state.intersect_shape(shape_query)
	return result.size() > 0

# Fungsi ini dipanggil jika kamu menyambungkan signal Aris ke World di Editor
func _on_aris_darah_berubah(darah_sekarang: Variant) -> void:
	# Teruskan data darah dari Aris ke script UIGame
	if has_node("CanvasLayer/UIGame"):
		$CanvasLayer/UIGame._on_player_darah_berubah(darah_sekarang)
