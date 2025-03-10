extends CharacterBody2D

# Karakteriniz için ayarlanabilir değişkenler
@export var speed = 200.0
@export var jump_force = 300.0
@export var gravity = 980.0
@export var swim_speed = 150.0

# Karakter durumları için enum
enum States {IDLE, WALK, JUMP, FALL, SWIM}
var current_state = States.IDLE
var is_in_water = false

func _ready():
	# Animasyon oynatıcısını al
	var anim_player = $AnimationPlayer
	
	# Varsayılan animasyonu oynat
	anim_player.play("idle")

func _physics_process(delta):
	# Karakter hızını al
	var velocity = Vector2.ZERO
	
	# Yer çekimini uygula (suda değilse)
	if not is_in_water:
		velocity.y += gravity * delta
	else:
		velocity.y += gravity * delta * 0.3  # Suda yer çekimi daha az etkiler
	
	# Hareket girdilerini işle
	var direction = Input.get_axis("ui_left", "ui_right")
	
	if direction:
		velocity.x = direction * (swim_speed if is_in_water else speed)
		# Karakterin yönünü ayarla
		$Sprite2D.flip_h = direction < 0
	else:
		velocity.x = 0
	
	# Zıplama girdisini işle
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = -jump_force
		elif is_in_water:
			velocity.y = -swim_speed * 1.2  # Suda daha hafif zıplama
	
	# Durumu güncelle ve animasyonu ayarla
	update_animation_state(velocity)
	
	# Hareketi uygula
	set_velocity(velocity)
	move_and_slide()

func update_animation_state(velocity):
	var anim_player = $AnimationPlayer
	
	# Hali hazırda oynatılan animasyonu tekrar oynatma
	var current_animation = anim_player.current_animation
	var new_animation = ""
	
	# Durum belirleme
	if is_in_water:
		new_animation = "swim"
	elif not is_on_floor():
		# if-else kullanıyoruz
		if velocity.y < 0:
			new_animation = "jump"
		else:
			new_animation = "fall"
	elif abs(velocity.x) > 0.1:
		new_animation = "walk"
	else:
		new_animation = "idle"
	
	# Sadece animasyon değiştiğinde oynat
	if new_animation != current_animation:
		anim_player.play(new_animation)
	
	# Durum değiştiyse animasyonu güncelle
	if current_state != prev_state:
		match current_state:
			States.IDLE:
				anim_player.play("idle")
			States.WALK:
				anim_player.play("walk")
			States.JUMP:
				anim_player.play("jump")
			States.FALL:
				anim_player.play("fall")
			States.SWIM:
				anim_player.play("swim")

# Su girme/çıkma tespiti
func _on_water_detector_body_entered(body):
	if body.is_in_group("water"):
		is_in_water = true

func _on_water_detector_body_exited(body):
	if body.is_in_group("water"):
		is_in_water = false
