extends Node2D

var player := Vector2(320, 180)
var speed := 180.0
var message := "Walk to the NPC and press E."

func _process(delta):
	var direction := Vector2.ZERO

	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		direction.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direction.x += 1
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		direction.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		direction.y += 1

	if direction != Vector2.ZERO:
		player += direction.normalized() * speed * delta

	player.x = clamp(player.x, 20.0, 620.0)
	player.y = clamp(player.y, 70.0, 335.0)

	if Input.is_key_pressed(KEY_E) and player.distance_to(Vector2(500, 150)) < 70:
		message = "NPC: Welcome to the simplest RPG in Ashwood!"

	queue_redraw()

func _draw():
	draw_rect(Rect2(0, 0, 640, 360), Color("#17202a"))
	draw_rect(Rect2(20, 70, 600, 265), Color("#315a3b"))

	# path
	draw_rect(Rect2(20, 250, 600, 55), Color("#8c7453"))

	# NPC
	draw_circle(Vector2(500, 150), 14, Color("#e0a06a"))
	draw_rect(Rect2(487, 164, 26, 30), Color("#70558a"))
	draw_string(ThemeDB.fallback_font, Vector2(475, 215), "NPC", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)

	# player
	draw_rect(Rect2(player - Vector2(12, 12), Vector2(24, 24)), Color("#e05f5f"))
	draw_circle(player - Vector2(0, 17), 9, Color("#e3b17d"))

	# UI
	draw_rect(Rect2(0, 0, 640, 55), Color("#10151c"))
	draw_string(ThemeDB.fallback_font, Vector2(20, 34), "TINY RPG DEMO", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#f1d28a"))
	draw_string(ThemeDB.fallback_font, Vector2(365, 33), "WASD / Arrows   E: Talk", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#d8dce3"))

	draw_rect(Rect2(20, 315, 600, 30), Color("#10151c"))
	draw_string(ThemeDB.fallback_font, Vector2(30, 337), message, HORIZONTAL_ALIGNMENT_LEFT, 580, 14, Color.WHITE)
