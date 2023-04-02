extends CanvasLayer

signal game_restart
var game_running = false
var colors = {"asia":{"Up":Color8(255,255,173),"Bottom":Color8(52,152,219)},
"europe":{"Up":Color8(176, 137, 86),"Bottom":Color8(158, 47, 47)}}

var currentColor = "asia"


func _process(delta):
	if (game_running):
		$TimeLabel.text = str(int($TimeOver.time_left)) + " s"
	else:
		$TimeLabel.text = "60 s"

func updateScreenFilter(balance):
	var cur = colors[currentColor]
	if balance > 2:
		var color = cur["Up"]
		color.a = (balance-2.0)/4.0
		$EmotionLayer.color = color
	elif balance == 2:
		$EmotionLayer.color = Color8(0,0,0,0)
	else:
		var color = cur["Bottom"]
		color.a = (2.0-balance)/4.0
		$EmotionLayer.color = color
		$EmotionLayer.color = color


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


func _on_player_game_finish(balance, skills_stats):
	var timeStat = $TimeOver.time_left
	$TimeOver.stop()
	game_running = false
	$EmotionLayer.color = Color(180.0/255.0,24./255.,214./255.)
	var msg = "Nice Dream!\n"
	msg += "Time "+str(int(timeStat)) + " s\n"
	msg += "Balance "+str(balance-2)+"\n"
	msg += "Cried "+str(skills_stats["Cry"])+" times\n"
	msg += "Flied  "+str(skills_stats["Fly"])+" times\n"
	$Label.text = msg
	$RestartButton.show()
	

func _on_restart_button_button_down():
		$RestartButton.hide()
		emit_signal("game_restart")
		$Label.text = ""
		$EmotionLayer.color = Color(0,0,0,0)


func _on_player_color_change(current_dragon, balance):
	currentColor = current_dragon
	var cur = colors[current_dragon]
	$EmotionBar/Up.color = cur["Up"]
	$EmotionBar/Botttom.color = cur["Bottom"]
	updateScreenFilter(balance)
