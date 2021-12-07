def cost(x)
  (1..x).sum
end

c = File.read(ARGV[0]).strip.split(/,/).map(&.to_i)
res = (1..c.size).map do |i|
  c.map { |x| cost((x - i).abs) }.sum
end.min
puts res
