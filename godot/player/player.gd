extends CharacterBody2D

enum MoveDirection {LEFT, RIGHT}

const SPEED = 300.0
const ACCELERATION = 10

signal skill_used(skill_type, node_name)
signal balance_change(current_balance)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready
var animation_player = $AnimationPlayer
@onready
var sprite_player = $Sprite2D
var direction = MoveDirection.RIGHT
var current_skill = "Fly"
var current_view = Vector2.ZERO
var in_action = false

func _process(delta):
	if in_action:
		pass
	elif Input.is_action_just_pressed("interact"):	
		skill(delta)
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
		current_view = Vector2(areaPos.x*64,areaPos.y*100)
		$interactiveArea.position = Vector2(areaPos.x*64,areaPos.y*100)

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
	in_action = true
	$AnimStart.start()
	animation_player.play(current_skill)
	use_skill()
	emit_signal("skill_used", "skill")
	
func use_skill():
	
	if current_skill == "Cry":
		await $AnimStart.timeout
	elif current_skill == "Fly":
		await $AnimStart.timeout
		$AnimEnd.start()
		var view_norm = current_view.normalized()
		var col_size =  $collision.shape.size + Vector2(100,100)
		position = position + Vector2(view_norm.x*col_size.x,view_norm.y*col_size.y)
		move_and_slide()

	in_action = false
