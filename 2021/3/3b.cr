h = Hash(Int32, Int32).new(0)
raw = File.read(ARGV[0]).lines
s = raw[0].size
lines = raw
(0...s).each do |i|
  c = 0
  lines.each { |l| c += 1 if l[i] == '1' }
  t = c >= lines.size / 2 ? '1' : '0'
  lines = lines.select { |l| l[i] == t }
  break if lines.size == 1
end
o = lines[0].to_i(2)
lines = raw
(0...s).each do |i|
  c = 0
  lines.each { |l| c += 1 if l[i] == '1' }
  t = c >= lines.size / 2 ? '0' : '1'
  lines = lines.select { |l| l[i] == t }
  break if lines.size == 1
end
co2 = lines[0].to_i(2)
puts o * co2
