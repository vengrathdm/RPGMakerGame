# Clean the RPG Maker XP script database.
# Main must remain the final executable script entry. Any script entry after
# Main is outside the normal XP script order and is removed.

path = "Data/Scripts.rxdata"
data = Marshal.load(File.binread(path))

main_index = data.rindex do |entry|
  entry.is_a?(Array) && entry.length >= 3 && entry[1].to_s.strip == "Main"
end

abort "Could not find RPG Maker XP Main script" unless main_index

removed = data.length - main_index - 1
data.slice!(main_index + 1, removed) if removed > 0

File.binwrite(path, Marshal.dump(data))
puts "Removed #{removed} script entries after Main"
