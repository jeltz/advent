File.read(ARGV[0]).chomp =~ /^target area: x=(-?\d+)\.\.(-?\d+), y=(-?\d+)\.\.(-?\d+)$/
minx, maxx, miny, maxy = $1.to_i, $2.to_i, $3.to_i, $4.to_i

best = 0
iy = miny
loop do
  (1..maxx).each do |ix|
    dx, dy = ix, iy
    x, y = 0, 0
    high = 0
    while x <= maxx && y >= miny
      x += dx
      y += dy
      high = [high, y].max
      dx = [0, dx - 1].max
      dy -= 1
      if (minx..maxx).includes?(x) && (miny..maxy).includes?(y)
        best = [best, high].max
        puts best
        break
      end
    end
  end
  iy += 1
end
# Note: Never exits, use last line
