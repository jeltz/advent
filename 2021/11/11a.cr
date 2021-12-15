def f(b, x, y)
  return if x < 0 || x > 9 || y < 0 || y > 9
  b[x][y] += 1
  if b[x][y] == 10
    f(b, x - 1, y - 1)
    f(b, x - 1, y + 0)
    f(b, x - 1, y + 1)
    f(b, x + 0, y - 1)
    f(b, x + 0, y + 1)
    f(b, x + 1, y - 1)
    f(b, x + 1, y + 0)
    f(b, x + 1, y + 1)
  end
end

b = File.read(ARGV[0]).lines.map { |l| l.chars.map { |c| c.to_i } }

flashes = 0

100.times do
  (0...10).each do |x|
    (0...10).each do |y|
      f(b, x, y)
    end
  end

  (0...10).each do |x|
    (0...10).each do |y|
      if b[x][y] >= 10
        flashes += 1
        b[x][y] = 0
      end
    end
  end
end

puts flashes
