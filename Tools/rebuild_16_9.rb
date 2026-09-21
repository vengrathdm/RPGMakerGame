# Rebuild Data/Scripts.rxdata with the generated 16:9 RGSS core.
require "zlib"
path="Data/Scripts.rxdata"
data=Marshal.load(File.binread(path))
name="RPGMakerGame - 16:9 Core"
src=File.binread("Tools/rgss/rpgmakergame_16_9_core.rb")
data.delete_if{|e| e.is_a?(Array) && e[0].to_s==name}
entry=[name,Zlib::Deflate.deflate(src)]
idx=data.index{|e| e.is_a?(Array) && e[0].to_s=="Main"}
idx ? data.insert(idx,entry) : data << entry
File.binwrite(path,Marshal.dump(data))
puts "16:9 core injected"
