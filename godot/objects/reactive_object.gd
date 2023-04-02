extends Node
@export_enum("water", "bridge", "rock") var object_type: String = "water"
const WaterObjectType = preload("res://objects/water.tscn")
const BridgeObjectType = preload("res://objects/bridge.tscn")

var player_in_range = false
var object = null
# Called when the node enters the scene tree for the first time.
func _ready():
	$Active.hide()
	var player = get_parent().get_node("player")
	var area2d = get_node("Area2D")

	match object_type:
		"water":
			object = WaterObjectType.instantiate()
		"bridge":
			object = BridgeObjectType.instantiate()
		"rock":
			pass
			
	if object != null:
		$Sprite2D.hide()
		self.add_child(object)

	player.connect("skill_tried", _on_player_skill_tried)
	area2d.connect("area_entered", _on_area_entered)
	area2d.connect("area_exited", _on_area_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_player_skill_tried(player):
	if player_in_range:
		print("looking for skill: ", object.required_skill)
		if (player.can_use_skill(object.required_skill)):
			print("calling for skill use")
			player.use_skill(object.required_skill)
			if object != null:
				object.do_action()
		else:
			print("skill couldn't be used")

func _on_area_entered(body):
	$Active.show()
	player_in_range = true
	print("area entered: ", body.get_parent().name)
	
func _on_area_exited(body):
	$Active.hide()
	player_in_range = false
	print("area exited")
