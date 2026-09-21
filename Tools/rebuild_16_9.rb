# Restore the native RPG Maker XP script database.
# The previous injected RGSS core caused the engine to fail during script loading.
# Keep the original Scripts.rxdata intact until the renderer implementation is
# validated against RGSS1 itself.

require "zlib"

path = "Data/Scripts.rxdata"
data = Marshal.load(File.binread(path))
name = "RPGMakerGame - 16:9 Gameplay Core"

removed = data.delete_if do |entry|
  entry.is_a?(Array) && entry.length >= 3 && entry[1].to_s == name
end

File.binwrite(path, Marshal.dump(data))
puts "Removed #{removed ? 1 : 0} experimental 16:9 core script"
