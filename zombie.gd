extends CharacterBody2D

@onready var sprite := $AnimatedSprite2D
@onready var hitbox := $Hitbox # Area untuk melukai Aris

var sudah_mati : bool = false
var health : int = 5
var kecepatan = 60.0
var target_player = null
var jarak_serang = 35.0

func _ready():
	sprite.play("idle")
	# Hitbox zombie digunakan untuk menerima serangan dari Aris
	hitbox.area_entered.connect(kena_serang)
	
	# Cek apakah DetectionArea ada
	if has_node("DetectionArea"):
		$DetectionArea.body_entered.connect(_on_detection_body_entered)
		$DetectionArea.body_exited.connect(_on_detection_body_exited)

func _physics_process(_delta):
	if sudah_mati or target_player == null:
		return
		
	var jarak = global_position.distance_to(target_player.global_position)
	var arah = (target_player.global_position - global_position).normalized()
	
	if jarak <= jarak_serang:
		velocity = Vector2.ZERO
		pilih_animasi_serang(arah)
	else:
		velocity = arah * kecepatan
		sprite.play("idle")
		sprite.flip_h = arah.x < 0
		
	move_and_slide()

func pilih_animasi_serang(arah: Vector2):
	if abs(arah.x) > abs(arah.y):
		sprite.play("serang_kanan")
		sprite.flip_h = arah.x < 0
	else:
		if arah.y > 0:
			sprite.play("serang_bawah")
		else:
			sprite.play("serang_atas")

func _on_detection_body_entered(body):
	if body.name == "Aris":
		target_player = body

func _on_detection_body_exited(body):
	if body == target_player:
		target_player = null

func kena_serang(area):
	if sudah_mati: return
	if area.name == "AtkBox": # Mendeteksi area serang Aris
		health -= 1
		if health <= 0:
			musuh_mati()

func musuh_mati():
	sudah_mati = true
	hitbox.set_deferred("monitoring", false)
	sprite.play("mati")
	await sprite.animation_finished
	queue_free()
