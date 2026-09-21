extends Node2D

const WORLD := Rect2(32, 54, 896, 438)
const SPEED := 185.0
var player := Vector2(330, 320)
var elder := Vector2(690, 160)
var well := Vector2(690, 205)
var slime := Vector2(565, 345)
var hp := 10
var gold := 12
var slime_hp := 3
var slime_alive := true
var quest := 0
var message := "Find Elder Rowan near the old well."
var message_time := 5.0
var game_won := false
var attack_cooldown := 0.0

func _ready():
	queue_redraw()

func _process(delta):
	if game_won:
		queue_redraw()
		return
	var dir := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): dir.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): dir.x += 1
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): dir.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): dir.y += 1
	player += dir.normalized() * SPEED * delta if dir.length() > 0 else Vector2.ZERO
	player.x = clamp(player.x, WORLD.position.x + 18, WORLD.end.x - 18)
	player.y = clamp(player.y, WORLD.position.y + 18, WORLD.end.y - 18)
	message_time = max(0.0, message_time - delta)
	attack_cooldown = max(0.0, attack_cooldown - delta)
	if Input.is_key_pressed(KEY_E) and message_time <= 0.0:
		interact()
	if Input.is_key_pressed(KEY_SPACE) and attack_cooldown <= 0.0:
		attack()
	if slime_alive and player.distance_to(slime) < 100 and randf() < delta * 0.25:
		hp -= 1
		message = "The slime hits you!"
		message_time = 1.2
		if hp <= 0:
			hp = 10
			player = Vector2(330,320)
			message = "You wake beside the road."
			message_time = 2
	queue_redraw()

func interact():
	if player.distance_to(elder) < 90:
		if quest == 0:
			quest = 1
			message = "Rowan: A slime stole my lantern! Defeat it and return here."
		elif quest == 1:
			message = "Rowan: The slime is east of the well."
		elif quest == 2:
			quest = 3
			gold += 30
			game_won = true
			message = "Rowan: You saved Ashwood. Take this gold!"
		message_time = 4
	elif player.distance_to(well) < 65:
		message = "The old well is dry. Blue light flickers below."
		message_time = 3

func attack():
	attack_cooldown = 0.3
	if slime_alive and player.distance_to(slime) < 75:
		slime_hp -= 1
		message = "Hit! Slime HP: %d/3" % slime_hp
		message_time = 1.2
		if slime_hp <= 0:
			slime_alive = false
			quest = 2
			gold += 8
			message = "The slime dissolves. You recover Rowan's lantern!"
			message_time = 3

func _draw():
	draw_rect(Rect2(0,0,960,540), Color("#111827"))
	draw_rect(WORLD, Color("#29482f"))
	for x in range(14):
		for y in range(6):
			draw_circle(Vector2(55+x*64,80+y*70), 1.5, Color("#3b6040"))
	var path = PackedVector2Array([Vector2(70,390),Vector2(250,340),Vector2(410,365),Vector2(560,280),Vector2(690,205),Vector2(860,170)])
	draw_polyline(path, Color("#9a805d"), 38, true)
	for p in [Vector2(95,105),Vector2(175,180),Vector2(260,105),Vector2(360,145),Vector2(820,105),Vector2(870,270),Vector2(790,410),Vector2(120,455)]:
		tree(p)
	draw_rect(Rect2(620,105,145,85),Color("#8b5a3c"))
	draw_colored_polygon(PackedVector2Array([Vector2(600,108),Vector2(690,55),Vector2(785,108)]),Color("#4b2631"))
	draw_string(ThemeDB.fallback_font,Vector2(640,98),"ELDER'S HOUSE",HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("#f6dfb2"))
	draw_circle(well,28,Color("#54483d"))
	draw_circle(well,20,Color("#171c25"))
	characters()
	ui()

func tree(p):
	draw_rect(Rect2(p+Vector2(-7,12),Vector2(14,30)),Color("#593d2c"))
	draw_circle(p+Vector2(-18,2),24,Color("#173b2a"))
	draw_circle(p+Vector2(12,-5),28,Color("#1d4a2d"))
	draw_circle(p+Vector2(0,-24),25,Color("#245a34"))

func characters():
	draw_circle(elder,15,Color("#d7a36b"))
	draw_rect(Rect2(elder+Vector2(-17,14),Vector2(34,30)),Color("#7c5a8e"))
	draw_string(ThemeDB.fallback_font,elder+Vector2(-35,50),"ROWAN",HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("#f6dfb2"))
	if slime_alive:
		draw_circle(slime+Vector2(0,7),27,Color("#5ac3a6"))
		draw_circle(slime+Vector2(-10,-2),5,Color("#b9f4df"))
		draw_circle(slime+Vector2(10,-2),5,Color("#b9f4df"))
		draw_circle(slime+Vector2(-10,-1),2.5,Color("#18232a"))
		draw_circle(slime+Vector2(10,-1),2.5,Color("#18232a"))
		draw_string(ThemeDB.fallback_font,slime+Vector2(-20,45),"SLIME",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("#c5f5e8"))
	draw_circle(player+Vector2(0,-9),13,Color("#e3b17d"))
	draw_rect(Rect2(player+Vector2(-15,5),Vector2(30,28)),Color("#d96b5f"))
	draw_rect(Rect2(player+Vector2(-13,-22),Vector2(26,10)),Color("#263f62"))
	draw_rect(Rect2(player+Vector2(-12,31),Vector2(9,12)),Color("#25283a"))
	draw_rect(Rect2(player+Vector2(3,31),Vector2(9,12)),Color("#25283a"))
	draw_line(player+Vector2(14,10),player+Vector2(28,-4),Color("#d9d0b8"),5)

func ui():
	draw_rect(Rect2(0,0,960,54),Color("#17151f"))
	draw_string(ThemeDB.fallback_font,Vector2(24,34),"ASHWOOD: THE LOST LANTERN",HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color("#f1d28a"))
	draw_string(ThemeDB.fallback_font,Vector2(690,33),"WASD / Arrows   E: Talk   SPACE: Attack",HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("#c8c3d1"))
	draw_rect(Rect2(18,468,924,58),Color("#17151f"))
	draw_string(ThemeDB.fallback_font,Vector2(34,493),"HP: %d/10    GOLD: %d" % [hp,gold],HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("#f4d7d7"))
	var objective = ["Objective: Talk to Elder Rowan.","Objective: Defeat the slime east of the well.","Objective: Return to Rowan.","DEMO COMPLETE — Ashwood is safe!"][quest]
	draw_string(ThemeDB.fallback_font,Vector2(300,493),objective,HORIZONTAL_ALIGNMENT_LEFT,610,15,Color("#ddd8e6"))
	if message_time > 0:
		draw_rect(Rect2(230,70,500,54),Color("#17151f"))
		draw_string(ThemeDB.fallback_font,Vector2(250,103),message,HORIZONTAL_ALIGNMENT_LEFT,460,16,Color.WHITE)
	if game_won:
		draw_rect(Rect2(250,185,460,145),Color("#0d0e18"))
		draw_string(ThemeDB.fallback_font,Vector2(335,225),"ASHWOOD IS SAFE",HORIZONTAL_ALIGNMENT_LEFT,-1,30,Color("#f1d28a"))
		draw_string(ThemeDB.fallback_font,Vector2(305,265),"You recovered the lost lantern.",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color.WHITE)
		draw_string(ThemeDB.fallback_font,Vector2(315,295),"The demo is complete.",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color.WHITE)
