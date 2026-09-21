# RPGMakerGame 16:9 gameplay foundation for RPG Maker XP / RGSS1.
# Menus are intentionally untouched in this pass.
module RPGMakerGame169
  WIDTH=640
  HEIGHT=360
  module_function
  def resize_native
    Graphics.resize_screen(WIDTH,HEIGHT)
    true
  rescue Exception
    false
  end
  def resize_player_window
    find=Win32API.new("user32","FindWindow","PP","L")
    hwnd=find.call("RGSS Player",nil)
    return false if hwnd==0
    get_client=Win32API.new("user32","GetClientRect","LPP","I")
    get_window=Win32API.new("user32","GetWindowRect","LPPP","I")
    set_pos=Win32API.new("user32","SetWindowPos","LLIIIII","I")
    metrics=Win32API.new("user32","GetSystemMetrics","I","I")
    cr=[0,0,0,0].pack("l4"); get_client.call(hwnd,cr,cr)
    c=cr.unpack("l4"); cw=c[2]; ch=c[3]
    wr=[0,0,0,0].pack("l4"); get_window.call(hwnd,wr)
    w=wr.unpack("l4"); ow=w[2]-w[0]; oh=w[3]-w[1]
    fw=ow-cw; fh=oh-ch
    ow=WIDTH+fw; oh=HEIGHT+fh
    sw=metrics.call(0); sh=metrics.call(1)
    set_pos.call(hwnd,0,(sw-ow)/2,(sh-oh)/2,ow,oh,0)
    true
  rescue Exception
    false
  end
  def install
    native=resize_native
    resize_player_window unless native
    Graphics.frame_rate=60 rescue nil
  end
end
RPGMakerGame169.install

# Make the stock map viewport use the 16:9 height instead of assuming 480.
class Spriteset_Map
  alias rpgmakergame169_create_viewports create_viewports
  def create_viewports
    rpgmakergame169_create_viewports
    if @viewport1
      @viewport1.rect.height=RPGMakerGame169::HEIGHT
      @viewport2.rect.height=RPGMakerGame169::HEIGHT
      @viewport3.rect.height=RPGMakerGame169::HEIGHT
    end
  end
end
