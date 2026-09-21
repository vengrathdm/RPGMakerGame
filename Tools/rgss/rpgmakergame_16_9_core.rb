# RPG Maker XP / RGSS1 - native 16:9 gameplay resolution
# Menus are intentionally left untouched for this pass.

module RPGMakerGame169
  WIDTH  = 960
  HEIGHT = 540

  module_function

  def apply
    # RGSS1 exposes the render surface through Graphics.resize_screen.
    # This changes the actual game surface instead of merely resizing the
    # Windows client frame.
    Graphics.resize_screen(WIDTH, HEIGHT)

    # Keep the game running at the normal RPG Maker frame rate.
    Graphics.frame_rate = 60

    # Match the Windows client area to the render surface.
    hwnd = Win32API.new("user32", "FindWindow", "PP", "L").call("RGSS Player", nil)
    return if hwnd == 0

    get_window_rect = Win32API.new("user32", "GetWindowRect", "LP", "I")
    get_client_rect = Win32API.new("user32", "GetClientRect", "LP", "I")
    set_window_pos = Win32API.new("user32", "SetWindowPos", "LLIIIII", "I")
    get_system_metrics = Win32API.new("user32", "GetSystemMetrics", "I", "I")

    wr = [0, 0, 0, 0].pack("l4")
    cr = [0, 0, 0, 0].pack("l4")
    get_window_rect.call(hwnd, wr)
    get_client_rect.call(hwnd, cr)

    w = wr.unpack("l4")
    c = cr.unpack("l4")
    frame_w = (w[2] - w[0]) - c[2]
    frame_h = (w[3] - w[1]) - c[3]

    outer_w = WIDTH + frame_w
    outer_h = HEIGHT + frame_h
    screen_w = get_system_metrics.call(0)
    screen_h = get_system_metrics.call(1)

    x = (screen_w - outer_w) / 2
    y = (screen_h - outer_h) / 2

    set_window_pos.call(hwnd, 0, x, y, outer_w, outer_h, 0)
  rescue Exception
    # Resolution support should never prevent the base game from launching.
  end
end

RPGMakerGame169.apply
