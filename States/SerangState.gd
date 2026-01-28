extends State

const ARAH_MAP = {
	"ui_right": {"vec": Vector2.RIGHT},
	"ui_left":  {"vec": Vector2.LEFT},
	"ui_up":    {"vec": Vector2.UP},
	"ui_down":  {"vec": Vector2.DOWN}
}

func enter():
	var animasi = player.get_animasi()
	var arah_sekarang = get_arah_sekarang()	
	if arah_sekarang != Vector2.ZERO:
		player.arah_terakhir = arah_sekarang
	
	setup_animasi_serang(player.arah_terakhir, animasi)

func get_arah_sekarang():
	for action in ARAH_MAP.keys():
		if Input.is_action_pressed(action):
			return ARAH_MAP[action]["vec"]
	return Vector2.ZERO

func setup_animasi_serang(arah, animasi):
	const KECEPATAN_SLIDE = 150
	player.velocity = arah.normalized() * KECEPATAN_SLIDE
	
	# --- PERBAIKAN: Aktifkan AtkBox saat menyerang ---
	if player.has_node("AtkBox"):
		player.get_node("AtkBox").monitoring = true 
	
	if arah == Vector2.RIGHT:
		animasi.play("serang_kanan")
		animasi.scale.x = 1
	elif arah == Vector2.LEFT:
		animasi.play("serang_kanan")
		animasi.scale.x = -1
	elif arah == Vector2.UP:
		animasi.play("serang_atas")
	elif arah == Vector2.DOWN:
		animasi.play("serang_bawah")

func physics_update(_delta):
	var animasi = player.get_animasi()
	
	if Input.is_action_pressed("tombol_serang"):
		var arah_baru = get_arah_sekarang()
		if arah_baru != Vector2.ZERO and arah_baru != player.arah_terakhir:
			player.arah_terakhir = arah_baru
			setup_animasi_serang(player.arah_terakhir, animasi)
	else:
		# --- PERBAIKAN: Matikan AtkBox saat berhenti menyerang ---
		if player.has_node("AtkBox"):
			player.get_node("AtkBox").monitoring = false
		player.change_state("idle")
