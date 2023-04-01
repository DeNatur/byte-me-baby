extends Node2D

func _process(delta):
	setBalance(1)
	

func setBalance(upLevel):
	var bottomLevel = 4 - upLevel
	$Up.size.y = levelToHeight(upLevel)
	$Botttom.size.y = levelToHeight(bottomLevel)

func levelToHeight(level):
	if level == 0: 
		return 0
		
	if level == 1: 
		return 32
		
	if level == 2: 
		return 64
		
	if level == 3: 
		return 96
		
	if level == 4: 
		return 128
			
