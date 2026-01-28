extends CharacterBody2D

@onready var sprite := $AnimatedSprite2D
@onready var hitbox := $Hitbox
var sudah_mati : bool = false
var health : int = 3 # Zombie perlu 3 kali pukul baru mati

func _ready():
	sprite.play("idle")
	hitbox.area_entered.connect(kena_serang)

func kena_serang(area):
	if sudah_mati:
		return
	
	if area.name == "AtkBox":
		health -= 1 # Kurangi HP setiap kali kena pukul
		print("HP Zombie: ", health)
		
		if health <= 0:
			musuh_mati()
		else:
			# Opsional: Tambahkan efek kedip putih atau animasi kena pukul di sini
			pass

func musuh_mati():
	sudah_mati = true
	print("Zombie sedang mati...")
	
	# Matikan collision agar tidak bisa dipukul lagi saat sedang animasi mati
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)
	
	# Mainkan animasi mati yang sudah kamu buat
	sprite.play("mati")
	
	# Tunggu sampai animasi "mati" selesai sebelum menghapus zombie
	await sprite.animation_finished
	
	# Baru hapus dari game
	queue_free()
