h = Hash(Array(Int32), Int32).new(0)
File.each_line(ARGV[0]) do |l|
  if l =~ /^(\d+),(\d+) -> (\d+),(\d+)$/
    x1, y1, x2, y2 = $1.to_i, $2.to_i, $3.to_i, $4.to_i
    if x1 == x2
      ([y1, y2].min..[y1, y2].max).each { |y| h[[x1, y]] += 1 }
    elsif y1 == y2
      ([x1, x2].min..[x1, x2].max).each { |x| h[[x, y1]] += 1 }
    elsif (x2 - x1) == (y2 - y1) && x2 > x1
      (0..(x2 - x1)).each { |i| h[[x1 + i, y1 + i]] += 1 }
    elsif (x2 - x1) == (y2 - y1)
      (0..-(x2 - x1)).each { |i| h[[x1 - i, y1 - i]] += 1 }
    elsif (x2 - x1) == -(y2 - y1) && x2 > x1
      (0..(x2 - x1)).each { |i| h[[x1 + i, y1 - i]] += 1 }
    elsif (x2 - x1) == -(y2 - y1)
      (0..-(x2 - x1)).each { |i| h[[x1 - i, y1 + i]] += 1 }
    end
  end
end
puts h.count { |_, v| v > 1 }
