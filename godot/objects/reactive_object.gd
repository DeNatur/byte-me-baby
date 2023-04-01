extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	var player = get_parent().get_node("player")
	var area2d = get_node("Area2D")

	player.connect("skill_used", _on_player_skill_used)
	area2d.connect("area_entered", _on_area_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_skill_used(skill_type):
	print("skilled detected")
	
func _on_area_entered(body):
	print("area entered: ", body.get_parent().name)
	
