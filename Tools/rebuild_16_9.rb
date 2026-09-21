# Rebuild the RPG Maker XP script database with the proven custom-resolution core.
# 16:9 is implemented at the RGSS level: 1024x576, with the map/tilemap
# viewport rewritten by the injected core. Main remains the final script.
require "zlib"

path = "Data/Scripts.rxdata"
data = Marshal.load(File.binread(path))
name = "RPGMakerGame - 16:9 Gameplay Core"
source = File.binread("Tools/rgss/rpgmakergame_16_9_core.rb")

data.delete_if { |e| e.is_a?(Array) && e.length >= 3 && e[1].to_s == name }

main_index = data.rindex do |e|
  e.is_a?(Array) && e.length >= 3 && e[1].to_s.strip == "Main"
end
abort "Could not find Main" unless main_index

data.slice!(main_index + 1, data.length - main_index - 1) if main_index < data.length - 1

ids = data.map { |e| e.is_a?(Array) && e[0].is_a?(Integer) ? e[0] : 0 }
next_id = (ids.max || 0) + 1

data.insert(main_index, [next_id, name, Zlib::Deflate.deflate(source)])
File.binwrite(path, Marshal.dump(data))
puts "Injected #{name} before Main"
