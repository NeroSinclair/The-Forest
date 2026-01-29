extends CharacterBody2D

const KECEPATAN = 130
var state: State
var states = {}
var vel = Vector2.ZERO
var arah_terakhir = Vector2.RIGHT

# --- DATA DARAH ---
var darah = 10
var bisa_kena_damage = true

func _ready():
	# Load states (Sesuaikan path folder States/states)
	states["idle"] = load("res://States/IdleState.gd").new()
	states["jalan"] = load("res://States/JalanState.gd").new()
	states["serang"] = load("res://States/SerangState.gd").new()

	for s in states.values():
		s.player = self

	change_state("idle")
	
	# PENTING: Cek apakah node Hurtbox ada sebelum menyambungkan
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
	# Zombie kamu punya area bernama "Hitbox"
	if area.name == "Hitbox" and bisa_kena_damage:
		terima_damage(1)

func terima_damage(jumlah):
	darah -= jumlah
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
	$AnimatedSprite2D.play("mati") # Pastikan animasi "mati" sudah ada
	await $AnimatedSprite2D.animation_finished
	get_tree().reload_current_scene()

func _on_animated_sprite_2d_frame_changed() -> void:
	# Nama di world.tscn adalah "AtkBox"
	if has_node("AtkBox"):
		var attack_box := $AtkBox
		if $AnimatedSprite2D.animation.begins_with("serang") and $AnimatedSprite2D.frame == 1:
			attack_box.monitoring = true
			attack_box.set_deferred("disabled", false)
		else:
			attack_box.monitoring = false
			attack_box.set_deferred("disabled", true)
