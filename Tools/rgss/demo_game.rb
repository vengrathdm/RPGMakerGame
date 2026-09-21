#==============================================================================
# RPGMakerGame Demo - The Lantern of Ashvale
# RPG Maker XP / RGSS1
#
# Self-contained playable vertical slice. No external graphics are required.
#==============================================================================

class Scene_Demo
  TILE = 32
  MAP_W = 20
  MAP_H = 13
  SCREEN_W = TILE * MAP_W
  SCREEN_H = TILE * MAP_H + 64

  def main
    Graphics.resize_screen(SCREEN_W, SCREEN_H) rescue nil
    @running = true
    @quest = 0
    @player_x = 3
    @player_y = 10
    @npc_x = 15
    @npc_y = 7
    @merchant_x = 10
    @merchant_y = 4
    @message = "The road to Ashvale is strangely quiet."
    @message_timer = 240

    create_view
    draw_world

    while @running
      Graphics.update
      Input.update
      update
      draw_world if @dirty
    end

    dispose_view
  end

  def create_view
    @bitmap = Bitmap.new(SCREEN_W, SCREEN_H)
    @sprite = Sprite.new
    @sprite.bitmap = @bitmap
    @dirty = true
  end

  def dispose_view
    @sprite.bitmap = nil
    @bitmap.dispose
    @sprite.dispose
  end

  def update
    @dirty = false
    moved = false

    if Input.repeat?(Input::LEFT)
      moved = move_player(-1, 0)
    elsif Input.repeat?(Input::RIGHT)
      moved = move_player(1, 0)
    elsif Input.repeat?(Input::UP)
      moved = move_player(0, -1)
    elsif Input.repeat?(Input::DOWN)
      moved = move_player(0, 1)
    end

    if Input.trigger?(Input::C)
      interact
    elsif Input.trigger?(Input::B)
      @running = false
    end

    if moved
      @message_timer -= 1
      @dirty = true
    end

    if @message_timer > 0
      @message_timer -= 1
      @dirty = true if @message_timer == 0
    end
  end

  def blocked?(x, y)
    return true if x < 1 || y < 1 || x >= MAP_W - 1 || y >= MAP_H - 1

    # River
    return true if x >= 7 && x <= 8 && y >= 2 && y <= 10

    # Houses / rocks
    return true if x >= 2 && x <= 5 && y >= 2 && y <= 4
    return true if x >= 12 && x <= 16 && y >= 2 && y <= 4
    return true if x == 17 && y >= 8 && y <= 10

    false
  end

  def move_player(dx, dy)
    nx = @player_x + dx
    ny = @player_y + dy
    return false if blocked?(nx, ny)
    @player_x = nx
    @player_y = ny
    true
  end

  def interact
    dx = (@player_x - @npc_x).abs
    dy = (@player_y - @npc_y).abs
    if dx <= 1 && dy <= 1
      if @quest == 0
        @quest = 1
        @message = "Mira: The old watchtower lamp has gone dark. Find the ember crystal in the ruins."
      elsif @quest == 1
        if @player_x >= 17 && @player_y >= 8
          @quest = 2
          @message = "You recover a warm ember crystal from the ruins."
        else
          @message = "Mira: The ruins are east of the village. Bring me the ember crystal."
        end
      elsif @quest == 2
        @quest = 3
        @message = "Mira: You brought it back. Ashvale has a future again."
      else
        @message = "Mira: The watchtower is glowing again. Thank you."
      end
      @message_timer = 300
      @dirty = true
      return
    end

    if (@player_x - @merchant_x).abs <= 1 && (@player_y - @merchant_y).abs <= 1
      @message = "Old Renn: I sell courage, mostly. The rest is walking."
      @message_timer = 240
      @dirty = true
      return
    end

    if @player_x >= 17 && @player_y >= 8 && @quest == 1
      @quest = 2
      @message = "A pale crystal rises from the rubble. Quest complete: Ember Crystal found."
      @message_timer = 300
      @dirty = true
      return
    end

    @message = "Nothing happens."
    @message_timer = 120
    @dirty = true
  end

  def draw_world
    @bitmap.clear
    draw_background
    draw_structures
    draw_characters
    draw_ui
    @dirty = false
  end

  def draw_background
    @bitmap.fill_rect(0, 0, SCREEN_W, SCREEN_H, Color.new(28, 52, 42))
    # grass
    0.step(SCREEN_W - 1, TILE) do |x|
      0.step(SCREEN_H - 65, TILE) do |y|
        if ((x / TILE) + (y / TILE)) % 2 == 0
          @bitmap.fill_rect(x, y, TILE, TILE, Color.new(42, 79, 48))
        else
          @bitmap.fill_rect(x, y, TILE, TILE, Color.new(38, 72, 45))
        end
      end
    end

    # road
    @bitmap.fill_rect(TILE, TILE * 8, TILE * 18, TILE * 3, Color.new(117, 91, 57))
    @bitmap.fill_rect(TILE * 9, TILE, TILE * 2, TILE * 10, Color.new(117, 91, 57))

    # river
    @bitmap.fill_rect(TILE * 7, TILE * 2, TILE * 2, TILE * 9, Color.new(38, 91, 132))
    2.upto(10) do |y|
      @bitmap.fill_rect(TILE * 7, TILE * y + 8, TILE * 2, 2, Color.new(86, 148, 180))
    end
  end

  def draw_structures
    house(2, 2, 4, 3, "MIRA'S HOUSE")
    house(12, 2, 5, 3, "ASHVALE INN")

    # watchtower / ruins
    @bitmap.fill_rect(TILE * 17, TILE * 8, TILE * 2, TILE * 3, Color.new(78, 70, 65))
    @bitmap.fill_rect(TILE * 17 + 8, TILE * 8 + 8, TILE * 48, 8, Color.new(117, 105, 91))
    @bitmap.fill_rect(TILE * 18 + 8, TILE * 8 + 20, TILE * 12, 40, Color.new(57, 51, 48))
    text("RUINS", TILE * 17, TILE * 10 + 4, 64, 20, 1)

    # sign
    @bitmap.fill_rect(TILE * 10 - 6, TILE * 6 - 10, 44, 30, Color.new(105, 70, 39))
    text("ASHVALE", TILE * 10 - 10, TILE * 6 - 6, 64, 18, 1)
  end

  def house(x, y, w, h, label)
    @bitmap.fill_rect(TILE * x, TILE * y, TILE * w, TILE * h, Color.new(112, 77, 57))
    @bitmap.fill_rect(TILE * x, TILE * y, TILE * w, 14, Color.new(72, 48, 44))
    @bitmap.fill_rect(TILE * x + 10, TILE * y + TILE * h - 28, 20, 28, Color.new(54, 40, 36))
    text(label, TILE * x, TILE * y + 8, TILE * w, 18, 1)
  end

  def draw_characters
    # player
    @bitmap.fill_rect(@player_x * TILE + 7, @player_y * TILE + 5, 18, 22, Color.new(219, 180, 90))
    @bitmap.fill_rect(@player_x * TILE + 10, @player_y * TILE + 2, 12, 9, Color.new(232, 191, 145))
    text("YOU", @player_x * TILE - 4, @player_y * TILE - 18, 40, 18, 1)

    # Mira
    @bitmap.fill_rect(@npc_x * TILE + 8, @npc_y * TILE + 5, 16, 22, Color.new(126, 76, 142))
    @bitmap.fill_rect(@npc_x * TILE + 10, @npc_y * TILE + 1, 12, 10, Color.new(232, 191, 145))
    text("MIRA", @npc_x * TILE - 10, @npc_y * TILE - 18, 52, 18, 1)

    # merchant
    @bitmap.fill_rect(@merchant_x * TILE + 8, @merchant_y * TILE + 5, 16, 22, Color.new(77, 117, 157))
    @bitmap.fill_rect(@merchant_x * TILE + 10, @merchant_y * TILE + 1, 12, 10, Color.new(232, 191, 145))
    text("RENN", @merchant_x * TILE - 8, @merchant_y * TILE - 18, 48, 18, 1)

    # crystal
    if @quest == 1
      cx = TILE * 18 + 12
      cy = TILE * 9
      @bitmap.fill_rect(cx, cy, 10, 20, Color.new(110, 210, 235))
      @bitmap.fill_rect(cx + 4, cy - 5, 4, 8, Color.new(180, 240, 255))
    end
  end

  def draw_ui
    y = TILE * MAP_H
    @bitmap.fill_rect(0, y, SCREEN_W, 64, Color.new(17, 22, 27))
    @bitmap.fill_rect(8, y + 7, SCREEN_W - 16, 50, Color.new(31, 39, 46))
    text("THE LANTERN OF ASHVALE", 18, y + 11, 270, 18, 0)
    objective = case @quest
      when 0 then "Talk to Mira."
      when 1 then "Find the ember crystal in the eastern ruins."
      when 2 then "Return to Mira."
      else "Ashvale is safe. Explore."
    end
    text(objective, 300, y + 11, 420, 18, 0)
    text("Arrows/WASD: Move   Enter/Space: Interact   Esc: Quit", 18, y + 34, 600, 18, 0)

    if @message_timer > 0
      @bitmap.fill_rect(24, 22, SCREEN_W - 48, 46, Color.new(8, 12, 16))
      text(@message, 36, 35, SCREEN_W - 72, 22, 0)
    end
  end

  def text(str, x, y, w, h, align)
    @bitmap.font.name = "Arial"
    @bitmap.font.size = 14
    @bitmap.font.bold = true
    @bitmap.draw_text(x, y, w, h, str.to_s, align)
  end
end

# Replace the stock title scene for the demo. The normal RPG Maker Main loop
# remains in control of the application.
class Scene_Title
  alias rpgmakergame_original_main main
  def main
    $scene = Scene_Demo.new
  end
end
