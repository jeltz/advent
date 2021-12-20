File.open(ARGV[0]) do |f|
  a = f.read_line.chars.map { |c| c == '#' }
  f.gets
  img = [] of Array(Bool)
  while (l = f.gets)
    img << l.chars.map { |c| c == '#' }
  end

  m = Hash(Tuple(Int32, Int32), Bool).new
  w, h = img[0].size, img.size
  (0...h).each do |i|
    (0...w).each do |j|
      m[{i, j}] = img[i][j]
    end
  end

  minx, miny, maxx, maxy = 0, 0, w - 1, h - 1
  inf = false
  2.times do
    minx -= 1
    miny -= 1
    maxx += 1
    maxy += 1

    n = Hash(Tuple(Int32, Int32), Bool).new
    (miny..maxy).each do |i|
      (minx..maxx).each do |j|
        k = (m.fetch({i - 1, j - 1}, inf) ? 1 << 8 : 0) |
            (m.fetch({i - 1, j + 0}, inf) ? 1 << 7 : 0) |
            (m.fetch({i - 1, j + 1}, inf) ? 1 << 6 : 0) |
            (m.fetch({i + 0, j - 1}, inf) ? 1 << 5 : 0) |
            (m.fetch({i + 0, j + 0}, inf) ? 1 << 4 : 0) |
            (m.fetch({i + 0, j + 1}, inf) ? 1 << 3 : 0) |
            (m.fetch({i + 1, j - 1}, inf) ? 1 << 2 : 0) |
            (m.fetch({i + 1, j + 0}, inf) ? 1 << 1 : 0) |
            (m.fetch({i + 1, j + 1}, inf) ? 1 << 0 : 0)
        n[{i, j}] = a[k]
      end
    end

    inf = a[inf ? 511 : 0]
    m = n
  end
  puts m.each_value.count { |v| v }
end
