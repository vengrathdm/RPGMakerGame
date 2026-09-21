# RPG Maker XP / RGSS1 16:9 custom-resolution core.
# Based on the established RGSS1 custom-resolution approach: the renderer
# remains XP, while the default 640x480 Viewport/Bitmap assumptions are
# redirected to the wider game surface.

module RPGMakerGame169
  SCREEN_W = 1024
  SCREEN_H = 576
  CENTER_X = SCREEN_W / 2
  CENTER_Y = SCREEN_H / 2

  class << self
    def install
      install_viewport
      install_bitmap
      install_sprite
      install_plane
      install_game_map
      resize_window
    end

    def install_viewport
      klass = Viewport
      return if klass.method_defined?(:rpgmakergame169_init)
      klass.class_eval do
        alias rpgmakergame169_initialize initialize
        def initialize(x=0, y=0, width=RPGMakerGame169::SCREEN_W, height=RPGMakerGame169::SCREEN_H, *args)
          if x.is_a?(Rect)
            rpgmakergame169_initialize(x)
          elsif x == 0 && y == 0 && width == 640 && height == 480
            rpgmakergame169_initialize(Rect.new(0, 0, RPGMakerGame169::SCREEN_W, RPGMakerGame169::SCREEN_H))
          else
            rpgmakergame169_initialize(Rect.new(x, y, width, height))
          end
        end
        alias rpgmakergame169_init initialize
      end
    end

    def install_bitmap
      klass = Bitmap
      return if klass.method_defined?(:rpgmakergame169_bitmap_init)
      klass.class_eval do
        alias rpgmakergame169_bitmap_initialize initialize
        def initialize(width=32, height=32, *args)
          if width.is_a?(String)
            rpgmakergame169_bitmap_initialize(width)
          elsif width == 640 && height == 480
            rpgmakergame169_bitmap_initialize(RPGMakerGame169::SCREEN_W, RPGMakerGame169::SCREEN_H)
          else
            rpgmakergame169_bitmap_initialize(width, height)
          end
        end
        alias rpgmakergame169_bitmap_init initialize
      end
    end

    def install_sprite
      klass = Sprite
      return if klass.method_defined?(:rpgmakergame169_sprite_init)
      klass.class_eval do
        alias rpgmakergame169_sprite_initialize initialize
        def initialize(viewport=nil)
          viewport ||= Viewport.new(0, 0, RPGMakerGame169::SCREEN_W, RPGMakerGame169::SCREEN_H)
          rpgmakergame169_sprite_initialize(viewport)
        end
        alias rpgmakergame169_sprite_init initialize
      end
    end

    def install_plane
      klass = Plane
      return if klass.method_defined?(:rpgmakergame169_plane_init)
      klass.class_eval do
        alias rpgmakergame169_plane_initialize initialize
        def initialize(viewport=nil)
          viewport ||= Viewport.new(0, 0, RPGMakerGame169::SCREEN_W, RPGMakerGame169::SCREEN_H)
          rpgmakergame169_plane_initialize(viewport)
        end
      end
    end

    def install_game_map
      klass = Game_Map
      return if klass.method_defined?(:rpgmakergame169_map_setup)
      klass.class_eval do
        alias rpgmakergame169_setup setup
        def setup(map_id)
          rpgmakergame169_setup(map_id)
          center = [RPGMakerGame169::CENTER_X - 16, 0].max
          @display_x = [@display_x, 0].max
          @display_y = [@display_y, 0].max
        end
        alias rpgmakergame169_map_setup setup
      end
    end

    def resize_window
      hwnd = Win32API.new("user32", "FindWindow", "PP", "L").call("RGSS Player", nil)
      return if hwnd == 0

      get_client = Win32API.new("user32", "GetClientRect", "LPP", "I")
      get_window = Win32API.new("user32", "GetWindowRect", "LPP", "I")
      set_pos = Win32API.new("user32", "SetWindowPos", "LLIIIII", "I")
      metrics = Win32API.new("user32", "GetSystemMetrics", "I", "I")

      cr = [0,0,0,0].pack("l4")
      wr = [0,0,0,0].pack("l4")
      get_client.call(hwnd, cr)
      get_window.call(hwnd, wr)
      c = cr.unpack("l4")
      w = wr.unpack("l4")
      frame_w = (w[2]-w[0]) - c[2]
      frame_h = (w[3]-w[1]) - c[3]

      ow = SCREEN_W + frame_w
      oh = SCREEN_H + frame_h
      sw = metrics.call(0)
      sh = metrics.call(1)
      set_pos.call(hwnd, 0, (sw-ow)/2, (sh-oh)/2, ow, oh, 0)
    rescue Exception
    end
  end
end

RPGMakerGame169.install
