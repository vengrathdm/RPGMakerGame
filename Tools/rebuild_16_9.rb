# Rebuild Data/Scripts.rxdata with the generated 16:9 RGSS core.
require "zlib"

path = "Data/Scripts.rxdata"
data = Marshal.load(File.binread(path))
name = "RPGMakerGame - 16:9 Gameplay Core"
src = File.binread("Tools/rgss/rpgmakergame_16_9_core.rb")

# RPG Maker XP stores script entries as [name, compressed_source].
data.delete_if do |entry|
  entry.is_a?(Array) && entry.length >= 2 && entry[0].to_s == name
end

entry = [name, Zlib::Deflate.deflate(src)]
main_index = data.index do |entry|
  entry.is_a?(Array) && entry.length >= 2 && entry[0].to_s == "Main"
end

main_index ? data.insert(main_index, entry) : data << entry

File.binwrite(path, Marshal.dump(data))
puts "16:9 core injected"
