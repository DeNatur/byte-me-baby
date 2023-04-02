extends Node

var required_skill = "Smash"

enum state {OFF, ON}

@onready
var sprites_anim = $AnimatedSprite2D

var current_state = state.ON
# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.connect("timeout", _on_timer_timeout)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func do_action():
	current_state = state.OFF
	$TimerAnim.start()
	sprites_anim.play("Broken")
	# Need to add waiting for animation to finish before the object is gone
	required_skill = "NoRocksNoSmash"
	await $TimerAnim.timeout
	get_parent().get_node("CollisionShape2D").call_deferred("set", "disabled", true)
	$AnimatedSprite2D.hide()
	$Timer.start()
	
func _on_timer_timeout():
	current_state = state.ON
	required_skill = "Smash"
	sprites_anim.play("NotBroken")
	$AnimatedSprite2D.show()
	get_parent().get_node("CollisionShape2D").call_deferred("set", "disabled", false)
	

