extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	$Active.hide()
	var player = get_parent().get_node("player")
	var area2d = get_node("Area2D")

	player.connect("skill_used", _on_player_skill_used)
	area2d.connect("area_entered", _on_area_entered)
	area2d.connect("area_exited", _on_area_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_skill_used(skill_type):
	print("skilled detected")
	
func _on_area_entered(body):
	$Active.show()
	print("area entered: ", body.get_parent().name)
	
func _on_area_exited(body):
	$Active.hide()
	print("area exited")
