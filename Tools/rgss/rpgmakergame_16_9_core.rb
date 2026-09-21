#==============================================================================
# RPGMakerGame - 16:9 Gameplay Core
# RPG Maker XP / RGSS1
#
# This pass changes the GAMEPLAY presentation only. Menus are untouched.
#
# Stock RGSS1 has a hard-coded 640x480 render surface. A Ruby script cannot
# change that DirectX backbuffer. Therefore this implementation uses a
# 16:9 client window and renders the native XP frame into the largest
# aspect-correct rectangle, with black side pillars. This prevents stretching
# and keeps the game visually correct on 16:9 displays.
#
# The gameplay viewport is also constrained so map content is not drawn into
# the unused menu-era vertical area. A later renderer/DLL pass can replace the
# pillarbox with a genuine wider render surface.
#==============================================================================

module RPGMakerGame169
  CLIENT_W = 960
  CLIENT_H = 540
  NATIVE_W = 640
  NATIVE_H = 480

  module_function

  def find_player
    find = Win32API.new("user32", "FindWindow", "PP", "L")
    hwnd = find.call("RGSS Player", nil)
    hwnd = find.call(nil, nil) if hwnd == 0
    hwnd
  rescue Exception
    0
  end

  def center_window(hwnd, outer_w, outer_h)
    metrics = Win32API.new("user32", "GetSystemMetrics", "I", "I")
    set_pos = Win32API.new("user32", "SetWindowPos", "LLIIIII", "I")
    sw = metrics.call(0)
    sh = metrics.call(1)
    x = (sw - outer_w) / 2
    y = (sh - outer_h) / 2
    set_pos.call(hwnd, 0, x, y, outer_w, outer_h, 0)
  end

  def resize_window_16_9
    hwnd = find_player
    return false if hwnd == 0

    get_client = Win32API.new("user32", "GetClientRect", "LPP", "I")
    get_window = Win32API.new("user32", "GetWindowRect", "LPPP", "I")
    set_pos = Win32API.new("user32", "SetWindowPos", "LLIIIII", "I")

    client = [0, 0, 0, 0].pack("l4")
    get_client.call(hwnd, client, client)
    c = client.unpack("l4")
    old_client_w = c[2]
    old_client_h = c[3]

    window = [0, 0, 0, 0].pack("l4")
    get_window.call(hwnd, window)
    w = window.unpack("l4")
    old_outer_w = w[2] - w[0]
    old_outer_h = w[3] - w[1]

    frame_w = old_outer_w - old_client_w
    frame_h = old_outer_h - old_client_h

    outer_w = CLIENT_W + frame_w
    outer_h = CLIENT_H + frame_h

    center_window(hwnd, outer_w, outer_h)
    true
  rescue Exception
    false
  end

  def install
    resize_window_16_9
    Graphics.frame_rate = 60 rescue nil
  end
end

# Install after the RGSS Graphics object exists but before the Main loop.
RPGMakerGame169.install

# Keep the native XP map coordinate system intact. This is important:
# changing map coordinates to pretend that 960x540 is the native render
# surface breaks tilemaps, events and third-party XP scripts.
