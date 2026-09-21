# Rebuild Data/Scripts.rxdata with the generated 16:9 RGSS core.
require "zlib"

path = "Data/Scripts.rxdata"
data = Marshal.load(File.binread(path))
name = "RPGMakerGame - 16:9 Gameplay Core"
src = File.binread("Tools/rgss/rpgmakergame_16_9_core.rb")

# RPG Maker XP stores script entries as [id, name, compressed_source].
# Keep the native three-field structure; malformed entries make RGSS report
# "Failed to load script" before any Ruby code can run.
data.delete_if do |entry|
  entry.is_a?(Array) && entry.length >= 2 && entry[1].to_s == name
end

ids = data.map do |entry|
  entry.is_a?(Array) && entry[0].is_a?(Integer) ? entry[0] : 0
end
next_id = ids.max + 1

entry = [next_id, name, Zlib::Deflate.deflate(src)]
main_index = data.index do |entry|
  entry.is_a?(Array) && entry.length >= 2 && entry[1].to_s == "Main"
end

main_index ? data.insert(main_index, entry) : data << entry

File.binwrite(path, Marshal.dump(data))
puts "16:9 core injected as RPG Maker XP script ##{next_id}"
