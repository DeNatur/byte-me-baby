extends Node

var required_skill = "Cry"

enum state {BURNING, NOT_BURNING}

@onready
var sprite_bridge = $BurningBridge

var current_state = state.BURNING
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func do_action():
	current_state = state.NOT_BURNING
	sprite_bridge.play("NotBurning")
	required_skill = "NoBridgeNoCry"
	get_parent().get_node("CollisionShape2D").call_deferred("set", "disabled", true)
	$Timer.start()
	
func _on_timer_timeout():
	current_state = state.BURNING
	sprite_bridge.play("Burning")
	required_skill = "Cry"
	get_parent().get_node("CollisionShape2D").call_deferred("set", "disabled", false)
	

