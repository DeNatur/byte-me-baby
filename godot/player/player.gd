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

var push_move = false
var roll_vector = Vector2.ZERO
var roll_vector_final_position = Vector2.ZERO
var ROLL_SPEED = 300

var current_dragon = "asia"
var current_view = Vector2.ZERO
var in_action = false
var skills = {"asia":{"Fly":-1,"Cry":1}, "europe":{"Smash":1,"Flame":-1}}
var skills_stats = {"Fly":0, "Cry":0, "Smash":0,"Flame":-1}
@onready
var animations = {"asia":$AnimationPlayer, "europe":$AnimationPlayer}
@onready
var sprites = {"asia":$Sprite2D, "europe":$TripToEu}
var game_started = false
var emotional_balance = {"europe":2,"asia":2}


func update_balance_skill(skill):
	skills_stats[skill]+=1
	emotional_balance[current_dragon] = get_new_balance(skill)
	emit_signal("balance_change", emotional_balance[current_dragon])

func get_new_balance(skill):
	var skill_value = skills[current_dragon][skill]
	return emotional_balance[current_dragon] + skill_value
	
func can_use_skill(skill):
	if skill in skills[current_dragon]:
		var new_balance = get_new_balance(skill)
		var in_balance = new_balance <= 4 and new_balance >=  0
		if not in_balance:
			emit_signal("game_over", new_balance)
		return in_balance
	return false

func _ready():
	emit_signal("balance_change", emotional_balance[current_dragon])
	
	

func swap_my_ass():
	if current_dragon == "asia":
		current_dragon = "europe"
	else:
		current_dragon = "asia"
	animation_player.pause()
	animation_player = animations[current_dragon]
	print(current_dragon)
	animation_player.clear_queue()
	sprite_player.hide()
	sprite_player = sprites[current_dragon]
	sprite_player.show()
	
func _process(delta):
	if in_action:
		pass
	elif Input.is_action_just_pressed("interact"):	
		skill(delta)
	elif Input.is_action_just_pressed("change"):	
		swap_my_ass()
	else:
		if push_move == true:
			roll(delta)
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

func roll(delta):
	var is_reached_end = false
	var delta_pos = position - roll_vector_final_position
	var acceptable_threshold = Vector2(1.0, 1.0)
	var dist_to_accpt_thrsh = floor(delta_pos.distance_to(acceptable_threshold))
	if dist_to_accpt_thrsh < 2:
		is_reached_end = true
	
	if is_reached_end:
		push_move = false
		$collision.call_deferred("set", "disabled", false)
		roll_vector = Vector2.ZERO
	else:	
		velocity = roll_vector * ROLL_SPEED
		$collision.call_deferred("set", "disabled", true)
		move_and_slide()

func set_animation(input_vector):
	if(input_vector.x > 0 ):
		sprite_player.set_flip_h(false)
		direction = MoveDirection.RIGHT
	elif(input_vector.x < 0):
		sprite_player.set_flip_h(true)
		direction = MoveDirection.LEFT

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
	animation_player.play(skill)
	update_balance_skill(skill)
	
	if skill == "Cry":
		await $AnimStart.timeout
	elif skill == "Fly":
		# await $AnimStart.timeout
		$AnimEnd.start()
		var view_norm = current_view.normalized()
		var col_size =  $collision.shape.size + Vector2(100,100)		
		# position = position + Vector2(view_norm.x*col_size.x,view_norm.y*col_size.y)
		# move_and_slide()

		roll_vector = Vector2(view_norm.x*col_size.x,view_norm.y*col_size.y).normalized()
		roll_vector_final_position = position + Vector2(view_norm.x*col_size.x,view_norm.y*col_size.y)		
		push_move = true
	
	in_action = false

func _on_hud_game_restart():
	emotional_balance = {"europe":2,"asia":2}
	game_started=false
	emit_signal("balance_change", emotional_balance[current_dragon])
	get_tree().reload_current_scene()


func _on_bed_body_entered(body):
	emit_signal("game_finish",emotional_balance[current_dragon], skills_stats)
