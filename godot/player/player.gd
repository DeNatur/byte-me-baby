extends CharacterBody2D

enum MoveDirection {LEFT, RIGHT}

const SPEED = 450.0
const ACCELERATION = 10

signal skill_tried(player_object)
signal balance_change(current_balance)
signal game_over(balance)
signal game_finish(balance, skills_stats)
signal game_start()

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready
var animation_player = $AnimationPlayer
@onready
var sprite_player = $Sprite2D
var direction = MoveDirection.RIGHT
var current_dragon = "asia"
var current_view = Vector2.ZERO
var in_action = false
var skills = {"asia":{"Fly":-1,"Cry":1}}
var skills_stats = {"Fly":0, "Cry":0}
var is_swapped = false
var game_started = false
var emotional_balance = 2


func update_balance_skill(skill):
	emotional_balance = get_new_balance(skill)
	emit_signal("balance_change", emotional_balance)

func get_new_balance(skill):
	var skill_value = skills[current_dragon][skill]
	return emotional_balance + skill_value
	
func can_use_skill(skill):
	if skill in skills[current_dragon]:
		var new_balance = get_new_balance(skill)
		var in_balance = new_balance <= 4 and new_balance >=  0
		if not in_balance:
			emit_signal("game_over", new_balance)
		return in_balance
	return false

func _ready():
	emit_signal("balance_change", emotional_balance)
	
	

func swap_my_ass():
	is_swapped = not is_swapped
	$AnimationPlayer.pause()
	$AnimationPlayer.clear_queue()
	sprite_player.hide()
	if (is_swapped):
		sprite_player = $TripToEu
	else:
		sprite_player = $Sprite2D
	sprite_player.show()
	
func _process(delta):
	if in_action:
		pass
	elif Input.is_action_just_pressed("interact"):	
		skill(delta)
	elif Input.is_action_just_pressed("change"):	
		swap_my_ass()
	else:
		move(delta)


func move(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()
	
	velocity = input_vector * SPEED
	velocity = velocity.move_toward(input_vector * SPEED, ACCELERATION * delta)
	set_animation(input_vector)
	move_and_slide()
	var areaPos = velocity.normalized()
	if (areaPos != Vector2.ZERO):
		if (!game_started):
			emit_signal("game_start")
			game_started = true
		current_view = Vector2(areaPos.x*64,areaPos.y*64) 
		$interactiveArea.position = $collision.position + current_view

func set_animation(input_vector):
	if(input_vector.x > 0 ):
		sprite_player.set_flip_h(false)
		direction = MoveDirection.RIGHT
	elif(input_vector.x < 0):
		sprite_player.set_flip_h(true)
		direction = MoveDirection.LEFT
	if (!is_swapped):
		if(input_vector != Vector2.ZERO):
			animation_player.play("Walk")
		else:
			set_idle_anim()

func set_idle_anim(): 
	animation_player.play("Idle")
	sprite_player.set_flip_h(direction == MoveDirection.LEFT)
			
func skill(delta):
	emit_signal("skill_tried", self)	

	
func use_skill(skill):
	in_action = true
	$AnimStart.start()
	if (!is_swapped):
		animation_player.play(skill)
	update_balance_skill(skill)
	
	if skill == "Cry":
		await $AnimStart.timeout
	elif skill == "Fly":
		await $AnimStart.timeout
		$AnimEnd.start()
		var view_norm = current_view.normalized()
		var col_size =  $collision.shape.size + Vector2(100,100)
		position = position + Vector2(view_norm.x*col_size.x,view_norm.y*col_size.y)
		move_and_slide()
	skills_stats[skill] += 1
	in_action = false

func _on_hud_game_restart():
	emotional_balance = 2
	game_started=false
	emit_signal("balance_change", emotional_balance)
	get_tree().reload_current_scene()

