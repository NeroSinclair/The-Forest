extends CharacterBody2D

# 1. Definisi Signal untuk mengirim data ke UI
signal darah_berubah(darah_sekarang)

@onready var sprite = $AnimatedSprite2D

const KECEPATAN = 130
var state: State
var states = {}
var vel = Vector2.ZERO
var arah_terakhir = Vector2.RIGHT

# --- DATA DARAH ---
# Diubah menjadi 10 agar sesuai dengan jumlah hati di UI
var darah = 10 
var bisa_kena_damage = true

func _ready():
	# 2. Emit signal di awal agar UI menampilkan 10 hati saat game mulai
	darah_berubah.emit(darah)
	
	# Load states
	states["idle"] = load("res://World/States/IdleState.gd").new()
	states["jalan"] = load("res://World/States/JalanState.gd").new()
	states["serang"] = load("res://World/States/SerangState.gd").new()

	for s in states.values():
		s.player = self

	change_state("idle")
	
	# Hubungkan Hurtbox
	if has_node("Hurtbox"):
		$Hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	else:
		print("Peringatan: Node Hurtbox belum dibuat di Editor!")

func get_animasi():
	return $AnimatedSprite2D
	
func change_state(new_state):
	if state:
		state.exit()
	state = states[new_state]
	state.enter()

func _input(event):
	state.handle_input(event)

func _process(delta):
	state.update(delta)

func _physics_process(delta):
	state.physics_update(delta)
	move_and_slide()

# --- FUNGSI DAMAGE ---
func _on_hurtbox_area_entered(area):
	# Pastikan area yang masuk bernama "Hitbox" (milik Zombie)
	if area.name == "Hitbox" and bisa_kena_damage:
		terima_damage(1)

func terima_damage(jumlah):
	darah -= jumlah
	
	# 3. Kirim data darah terbaru ke UI setiap kali kena hit
	darah_berubah.emit(darah) 
	
	# Efek visual flicker merah
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
	
	print("Darah Aris: ", darah)
	
	if darah <= 0:
		mati()
	else:
		mulai_invincibility()

func mulai_invincibility():
	bisa_kena_damage = false
	modulate.a = 0.5 
	await get_tree().create_timer(1.0).timeout 
	modulate.a = 1.0
	bisa_kena_damage = true

func mati():
	set_physics_process(false) # Berhenti bergerak
	$AnimatedSprite2D.play("mati") 
	await $AnimatedSprite2D.animation_finished
	# Reload scene saat mati
	get_tree().reload_current_scene()

func _on_animated_sprite_2d_frame_changed() -> void:
	if has_node("AtkBox"):
		var attack_box := $AtkBox
		if $AnimatedSprite2D.animation.begins_with("serang") and $AnimatedSprite2D.frame == 1:
			attack_box.monitoring = true
			attack_box.set_deferred("disabled", false)
		else:
			attack_box.monitoring = false
			attack_box.set_deferred("disabled", true)
