# Rebuild the RPG Maker XP script database with the native 16:9 core.
require "zlib"

path = "Data/Scripts.rxdata"
data = Marshal.load(File.binread(path))

name = "RPGMakerGame - 16:9 Gameplay Core"
source = File.binread("Tools/rgss/rpgmakergame_16_9_core.rb")

# Remove an earlier copy, wherever it is.
data.delete_if do |entry|
  entry.is_a?(Array) && entry.length >= 3 && entry[1].to_s == name
end

main_index = data.rindex do |entry|
  entry.is_a?(Array) && entry.length >= 3 && entry[1].to_s.strip == "Main"
end
abort "Could not find RPG Maker XP Main script" unless main_index

# Main must remain the final script. Remove anything that was below it.
data.slice!(main_index + 1, data.length - main_index - 1) if main_index < data.length - 1

# RPG Maker XP uses [id, name, compressed_source].
ids = data.map do |entry|
  entry.is_a?(Array) && entry[0].is_a?(Integer) ? entry[0] : 0
end
next_id = (ids.max || 0) + 1

entry = [next_id, name, Zlib::Deflate.deflate(source)]

# The core must execute before Main, but after the stock engine scripts.
data.insert(main_index, entry)

File.binwrite(path, Marshal.dump(data))
puts "Injected native 16:9 core as script #{next_id}; Main remains final"
