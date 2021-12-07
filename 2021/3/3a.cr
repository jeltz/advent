s, c = 0, 0
h = Hash(Int32, Int32).new(0)
File.each_line(ARGV[0]) do |l|
  s = l.size
  c += 1
  l.each_char.each_with_index { |b, i| h[i] += 1 if b == '1' }
end
g = (0...s).map { |i| h[i] > c / 2 ? "1" : "0" }.join.to_i(2)
e = (0...s).map { |i| h[i] < c / 2 ? "1" : "0" }.join.to_i(2)
puts g * e
