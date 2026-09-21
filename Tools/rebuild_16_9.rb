# Build the playable RPG Maker XP demo into Data/Scripts.rxdata.
require "zlib"

path = "Data/Scripts.rxdata"
data = Marshal.load(File.binread(path))

# Remove our generated scripts from previous builds.
generated = [
  "RPGMakerGame - 16:9 Gameplay Core",
  "RPGMakerGame - Ashvale Demo"
]
data.delete_if do |entry|
  entry.is_a?(Array) && entry.length >= 3 && generated.include?(entry[1].to_s)
end

main_index = data.rindex do |entry|
  entry.is_a?(Array) && entry.length >= 3 && entry[1].to_s.strip == "Main"
end
abort "Could not find RPG Maker XP Main script" unless main_index

# Main must remain the final script.
data.slice!(main_index + 1, data.length - main_index - 1) if main_index < data.length - 1

ids = data.map do |entry|
  entry.is_a?(Array) && entry[0].is_a?(Integer) ? entry[0] : 0
end
next_id = (ids.max || 0) + 1

source = File.binread("Tools/rgss/demo_game.rb")
entry = [next_id, "RPGMakerGame - Ashvale Demo", Zlib::Deflate.deflate(source)]
data.insert(main_index, entry)

File.binwrite(path, Marshal.dump(data))
puts "Injected playable Ashvale Demo as script #{next_id}"
