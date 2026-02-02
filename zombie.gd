extends CharacterBody2D

@onready var sprite := $AnimatedSprite2D
@onready var hitbox := $Hitbox

@export var kecepatan = 70.0
@export var jarak_serang = 40.0

var target_player = null
var sudah_mati : bool = false
var health : int = 3

func _ready():
	sprite.play("idle")
	# Koneksi signal hitbox (pastiin nama AtkBox di player bener)
	hitbox.area_entered.connect(kena_serang)
	
	# Koneksi signal deteksi otomatis biar gak ribet di editor
	if has_node("DetectionArea"):
		$DetectionArea.body_entered.connect(_on_detection_body_entered)
		$DetectionArea.body_exited.connect(_on_detection_body_exited)

func _physics_process(_delta):
	if sudah_mati:
		return
		
	if target_player:
		var jarak = global_position.distance_to(target_player.global_position)
		var arah = (target_player.global_position - global_position).normalized()
		
		if jarak <= jarak_serang:
			# Jarak serang: Berhenti dan serang
			velocity = Vector2.ZERO
			pilih_animasi_serang(arah)
		else:
			# Jarak kejar: Jalan ke arah player
			velocity = arah * kecepatan
			pilih_animasi_jalan(arah)
	else:
		# Tidak ada player: Berhenti dan idle
		velocity = Vector2.ZERO
		sprite.play("idle")
		
	move_and_slide()

# Fungsi buat nentuin animasi jalan (8-way atau flip)
func pilih_animasi_jalan(arah: Vector2):
	# Kalau lo punya animasi "jalan", pakai ini. 
	# Kalau belum ada, ganti "jalan" jadi "idle" dulu.
	if sprite.sprite_frames.has_animation("jalan"):
		sprite.play("jalan")
	else:
		sprite.play("idle") # Fallback kalau animasi jalan belum di-setup
	
	# Flip sprite berdasarkan arah kiri/kanan
	if arah.x != 0:
		sprite.flip_h = arah.x < 0

# Fungsi buat nentuin animasi serang (arah atas, bawah, samping)
func pilih_animasi_serang(arah: Vector2):
	if abs(arah.x) > abs(arah.y):
		sprite.play("serang_kanan")
		sprite.flip_h = arah.x < 0
	else:
		if arah.y > 0:
			sprite.play("serang_bawah")
		else:
			sprite.play("serang_atas")

# Signal Deteksi
func _on_detection_body_entered(body):
	if body.is_in_group("player"):
		target_player = body

func _on_detection_body_exited(body):
	if body == target_player:
		target_player = null

# Sistem Damage
func kena_serang(area):
	if sudah_mati: return
	if area.name == "AtkBox": 
		health -= 1
		# Efek flicker merah saat kena hit (opsional)
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color.RED, 0.1)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
		
		if health <= 0:
			musuh_mati()

func musuh_mati():
	sudah_mati = true
	velocity = Vector2.ZERO
	hitbox.set_deferred("monitoring", false)
	sprite.play("mati")
	await sprite.animation_finished
	queue_free()
