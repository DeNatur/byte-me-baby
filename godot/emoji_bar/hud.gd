extends CanvasLayer

signal game_restart

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
	
func _process(delta):
	updateScreenFilter(0)
	updateBar(1)
	
func set_game_over(msg):
	$Label.text = "Game Over!\n"+msg
	$Timer.start()
	await $Timer.timeout
	emit_signal("game_restart")
