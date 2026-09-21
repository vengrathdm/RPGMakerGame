require "zlib"

path = "Data/Scripts.rxdata"
data = Marshal.load(File.binread(path))

names = ["RPGMakerGame - 16:9 Gameplay Core", "RPGMakerGame - Ashvale Demo"]
data.delete_if { |e| e.is_a?(Array) && e.length >= 3 && names.include?(e[1].to_s) }

main_index = data.rindex { |e| e.is_a?(Array) && e.length >= 3 && e[1].to_s.strip == "Main" }
abort "Could not find Main" unless main_index

data.slice!(main_index + 1, data.length - main_index - 1) if main_index < data.length - 1

ids = data.map { |e| e.is_a?(Array) && e[0].is_a?(Integer) ? e[0] : 0 }
id = (ids.max || 0) + 1
src = File.binread("Tools/rgss/demo_game.rb")
data.insert(main_index, [id, "RPGMakerGame - Ashvale Demo", Zlib::Deflate.deflate(src)])

File.binwrite(path, Marshal.dump(data))
puts "Ashvale demo injected"
