extends CanvasLayer

signal game_restart
var game_running = false

func _process(delta):
	if (game_running):
		$TimeLabel.text = str(int($TimeOver.time_left)) + " s"
	else:
		$TimeLabel.text = "60 s"

func updateScreenFilter(balance):
	print(balance)
	if balance > 2:
		$EmotionLayer.color = Color(1,1,0,(balance-2.0)/4.0)
	elif balance == 2:
		$EmotionLayer.color = Color(0,0,0,0)
	else:
		$EmotionLayer.color = Color(0,0,1,(2.0-balance)/4.0)


func updateBar(balance):
	$EmotionBar.setBalance(balance)
	
	
func set_game_over(msg):
	$Label.text = "Game Over!\n"+msg
	$Timer.start()
	await $Timer.timeout
	emit_signal("game_restart")
	$Label.text = ""


func _on_player_balance_change(current_balance):
	updateScreenFilter(current_balance)
	updateBar(current_balance)


func _on_player_game_over(balance):
	updateScreenFilter(balance)
	game_running = false
	var msg = ""
	if balance > 2:
		msg = "Dragon was to excited. Dreamer woke up."
	else:
		msg = "Dragon couldn't fight through sadness."
	set_game_over(msg)
	

func _on_player_game_start():
	$TimeOver.start()
	game_running = true




func _on_time_over_timeout():
	updateScreenFilter(-1)
	game_running = false
	var msg = "Dragon run ouf of time"
	set_game_over(msg)
